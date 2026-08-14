#!/usr/bin/env ruby
# frozen_string_literal: true

# Asserts that Package.swift (Swift Package Manager) and the podspec (CocoaPods) allow the same versions of
# every shared dependency. If the two drift apart, SwiftPM consumers and CocoaPods consumers end up resolving
# different versions of the same library, and only one of them gets tested.
#
# Run it by hand from anywhere: ruby scripts/check-dependency-versions.rb
#
# ======================================================================================================
# What this understands, for whoever changes a dependency next
# ======================================================================================================
#
# Neither manifest is parsed here. Each package manager is asked to evaluate its own manifest and report what
# it resolved - `swift package dump-package` and `pod ipc spec`. That is why the list below is about
# *versions* and never about syntax: comments, line wrapping, `#{}` interpolation, hoisted constants, and
# however the dependency URL happens to be spelled are all resolved before this script sees anything. Write
# the manifests however reads best.
#
# Package.swift. SwiftPM normalises every version-based requirement into a range first, so all of these are
# indistinguishable by the time they arrive, and none of them need special handling here:
#
#     .package(url: …, from: "8.7.0")                    ->  [8.7.0, 9.0.0)
#     .package(url: …, .upToNextMajor(from: "8.7.0"))    ->  [8.7.0, 9.0.0)
#     .package(url: …, .upToNextMinor(from: "8.7.0"))    ->  [8.7.0, 8.8.0)
#     .package(url: …, "8.7.0"..<"13.0.0")               ->  [8.7.0, 13.0.0)
#     .package(url: …, "8.7.0"..."13.0.0")               ->  [8.7.0, 13.0.0]
#     .package(url: …, exact: "8.7.0")                   ->  [8.7.0, 8.7.0]
#
#   Dependencies are matched on SwiftPM's own `identity` ("firebase-ios-sdk"), not on the URL, so changing how
#   the URL is written cannot break the match. A `branch:` or `revision:` pin carries no version to compare
#   and is reported as a failure rather than skipped.
#
# The podspec. Requirement strings go straight to CocoaPods' own Pod::Requirement, so anything CocoaPods
# accepts works, including several requirements ANDed together:
#
#     spec.dependency "X", ">= 8.7.0", "< 13.0.0"        ->  [8.7.0, 13.0.0)
#     spec.dependency "X", "~> 8.7"                      ->  [8.7.0, 9.0.0)
#     spec.dependency "X", "~> 8.7.1"                    ->  [8.7.1, 8.8.0)
#     spec.dependency "X", "= 8.7.0"   (or just "8.7.0")  ->  [8.7.0, 8.7.0]
#     spec.dependency "X", "> 8.7.0", "<= 13.0.0"        ->  (8.7.0, 13.0.0]
#     spec.dependency "X", ">= 8.7.0"                     ->  [8.7.0, ∞)
#
#   Watch out for one thing: `pod ipc spec` groups dependencies by *where* they were declared. A dependency
#   added with `spec.ios.dependency` or inside a `spec.subspec` block does not appear under the top-level
#   "dependencies" key, so this script looks in all three places and ANDs together everything it finds. If the
#   same pod is pinned incompatibly in two places the result is an empty range, which is reported as a
#   failure. Semver build metadata such as "1.7.3+cio.1" is fine here (Pod::Version accepts it where
#   Gem::Version would not).
#
# Adding a shared dependency: add it to PAIRS below, or it simply will not be checked.
#
# Anything unreadable is reported as a failure, never as a pass. The version of this check that this replaced
# compared nothing at all for ten months, because it parsed the manifests with regular expressions that went
# stale and its failure path was only a warning (MBL-2247). Keep failures loud.
# ======================================================================================================

require 'json'
require 'open3'
# CocoaPods' own version classes rather than the RubyGems ones: identical `~>` behaviour, since this is what
# resolves a podspec, plus they accept semver build metadata that Gem::Version rejects outright.
begin
  require 'cocoapods-core'
rescue LoadError
  # A Homebrew-installed `pod` is a wrapper around its own private Ruby, so the gem can be missing from the
  # Ruby running this script even though `pod` works fine on the command line.
  abort "This needs the cocoapods gem visible to #{RbConfig.ruby}. Install it with `gem install cocoapods`, " \
        'or let CI run it - see .github/workflows/dependency-versions.yml.'
end

# CI folds stdout and stderr into one log, and stdout is buffered by default, so the summary would otherwise
# overtake the per-dependency lines.
$stdout.sync = true

# Anchored to the repository, not the working directory: both commands read their manifest by relative path,
# so taking the cwd would silently evaluate whatever manifests happened to be sitting there.
ROOT = File.expand_path('..', __dir__)

# SwiftPM's canonical identity paired with the pod name, which never matches it.
PAIRS = [
  {label: 'Firebase', spm_identity: 'firebase-ios-sdk', pod_name: 'FirebaseMessaging'},
  {label: 'Customer.io iOS SDK', spm_identity: 'customerio-ios', pod_name: 'CustomerIOMessagingPushFCM'}
].freeze

PLATFORM_KEYS = %w[ios osx macos tvos watchos visionos].freeze

# An inclusive-or-exclusive version interval; a nil bound means unbounded on that side. Pod::Version equality
# treats 8.7 and 8.7.0 as the same version, which is what comparing across two package managers needs.
Bounds = Struct.new(:lower, :lower_inclusive, :upper, :upper_inclusive) do
  def to_s
    "#{lower ? "#{lower_inclusive ? '[' : '('}#{lower}" : '(-∞'}, " \
      "#{upper ? "#{upper}#{upper_inclusive ? ']' : ')'}" : '∞)'}"
  end

  def satisfiable?
    return true if lower.nil? || upper.nil?
    return lower_inclusive && upper_inclusive if lower == upper

    lower < upper
  end

  def with_lower(version, inclusive)
    return self if lower && (version < lower)

    dup.tap do |b|
      b.lower = version
      b.lower_inclusive = version == lower ? (lower_inclusive && inclusive) : inclusive
    end
  end

  def with_upper(version, inclusive)
    return self if upper && (version > upper)

    dup.tap do |b|
      b.upper = version
      b.upper_inclusive = version == upper ? (upper_inclusive && inclusive) : inclusive
    end
  end
end

UNBOUNDED = Bounds.new(nil, false, nil, false).freeze

def capture_json(*command)
  stdout, stderr, status = Open3.capture3(*command, chdir: ROOT)
  detail = stderr.strip.empty? ? stdout.strip : stderr.strip
  abort "Could not read the manifests: `#{command.join(' ')}` failed.\n#{detail}" unless status.success?

  JSON.parse(stdout)
rescue JSON::ParserError => error
  abort "Could not read the manifests: `#{command.join(' ')}` did not produce JSON (#{error.message})."
rescue Errno::ENOENT
  abort "Could not read the manifests: `#{command.first}` is not installed."
end

def spm_bounds(dump, identity)
  sources = Array(dump['dependencies']).flat_map { |entry| Array(entry['sourceControl']) }
  source = sources.find { |candidate| candidate['identity'] == identity }
  raise "Package.swift declares no dependency with identity `#{identity}`" if source.nil?

  requirement = source['requirement'] || {}

  if (range = Array(requirement['range']).first)
    Bounds.new(Pod::Version.new(range['lowerBound']), true, Pod::Version.new(range['upperBound']), false)
  elsif (exact = Array(requirement['exact']).first)
    Bounds.new(Pod::Version.new(exact), true, Pod::Version.new(exact), true)
  else
    raise "Package.swift pins `#{identity}` by #{requirement.keys.join('/')} rather than by version, " \
          'which carries nothing to compare against a CocoaPods requirement'
  end
end

# Collects the pod's requirements from every place a podspec can declare them - see the note above about
# `pod ipc spec` grouping them by location - and intersects the lot.
def pod_requirements(node, pod_name)
  dependencies = node['dependencies']
  found = dependencies.is_a?(Hash) ? Array(dependencies[pod_name]) : []
  PLATFORM_KEYS.each { |key| found += pod_requirements(node[key], pod_name) if node[key].is_a?(Hash) }
  Array(node['subspecs']).each { |subspec| found += pod_requirements(subspec, pod_name) }
  found
end

def pod_bounds(spec, podspec, pod_name)
  requirements = pod_requirements(spec, pod_name)
  if requirements.empty?
    raise "#{podspec} declares no version requirement for `#{pod_name}` at the root, under a platform, " \
          'or in a subspec'
  end

  Pod::Requirement.new(requirements).requirements.reduce(UNBOUNDED) do |bounds, (operator, version)|
    case operator
    when '>=' then bounds.with_lower(version, true)
    when '>' then bounds.with_lower(version, false)
    when '<' then bounds.with_upper(version, false)
    when '<=' then bounds.with_upper(version, true)
    when '=' then bounds.with_lower(version, true).with_upper(version, true)
    when '~>' then bounds.with_lower(version, true).with_upper(version.bump, false)
    else raise "#{podspec} pins `#{pod_name}` with unsupported operator `#{operator}`"
    end
  end
rescue Pod::Requirement::BadRequirementError, ArgumentError => error
  raise "#{podspec} pins `#{pod_name}` with an unreadable requirement (#{error.message})"
end

podspecs = Dir.glob(File.join(ROOT, '*.podspec')).map { |path| File.basename(path) }.sort
unless podspecs.one?
  abort "Expected exactly one *.podspec in #{ROOT} but found #{podspecs.empty? ? 'none' : podspecs.join(', ')}. " \
        'Teach this script which podspec declares the shared dependencies.'
end

podspec = podspecs.first
dump = capture_json('swift', 'package', 'dump-package')
spec = capture_json('pod', 'ipc', 'spec', podspec)

failures = PAIRS.filter_map do |pair|
  spm = spm_bounds(dump, pair[:spm_identity])
  pod = pod_bounds(spec, podspec, pair[:pod_name])

  {'Package.swift' => spm, podspec => pod}.each do |file, bounds|
    raise "#{file} allows no version of #{pair[:label]} at all (#{bounds})" unless bounds.satisfiable?
  end

  if spm == pod
    puts "  OK   #{pair[:label]}: #{spm}"
    next
  end

  puts "  FAIL #{pair[:label]}: Package.swift allows #{spm}, #{podspec} allows #{pod}"
  "#{pair[:label]}: Package.swift allows #{spm} but #{podspec} allows #{pod}"
rescue RuntimeError => error
  puts "  FAIL #{pair[:label]}: #{error.message}"
  "#{pair[:label]}: #{error.message}"
end

if failures.empty?
  # Says what was compared rather than claiming agreement in general: only the PAIRS entries are checked.
  puts "\nAll #{PAIRS.count} checked dependencies agree between SwiftPM and CocoaPods."
  exit
end

warn "\nSwiftPM and CocoaPods disagree, so the two kinds of consumer would resolve different versions:"
failures.each { |failure| warn "  - #{failure}" }
warn "\nUpdate whichever manifest is wrong so both allow the same versions."
exit 1
