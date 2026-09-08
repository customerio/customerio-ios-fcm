Pod::Spec.new do |spec|
  spec.name         = "CioFirebaseWrapper"
  spec.version      = "1.0.1"
  spec.summary      = "Customer.io Firebase Wrapper SDK for iOS."
  spec.homepage     = "https://github.com/customerio/customerio-ios-fcm"
  spec.documentation_url = 'https://customer.io/docs/sdk/ios/'
  spec.changelog    = "https://github.com/customerio/customerio-ios-fcm/blob/#{spec.version.to_s}/CHANGELOG.md"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "CustomerIO Team" => "win@customer.io" }
  spec.source       = { :git => 'https://github.com/customerio/customerio-ios-fcm.git', :tag => spec.version.to_s }

  spec.swift_version = '5.5'
  spec.cocoapods_version = '>= 1.11.0'

  spec.platform = :ios
  spec.ios.deployment_target = "15.0"

  path_to_source_for_module = "Sources"
  spec.source_files = "#{path_to_source_for_module}/**/*{.swift}"
  
  spec.module_name = "CioFirebaseWrapper"
  
  # Add main SDK dependency. Upper bound mirrors `from: "4.0.0"` in Package.swift, which SwiftPM resolves
  # as ">= 4.0.0, < 5.0.0" - both package managers must allow the same versions.
  spec.dependency "CustomerIOMessagingPushFCM", ">= 4.0.0", "< 5.0.0"

  # Add Firebase dependency - 8.7.0 up to but excluding the next major after 12
  spec.dependency "FirebaseMessaging", ">= 8.7.0", "< 13.0.0"
end
