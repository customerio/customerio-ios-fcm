Pod::Spec.new do |spec|
  spec.name         = "CioFirebaseWrapper"
  spec.version      = "1.0.0"
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
  
  # Add main SDK dependency
  spec.dependency "CustomerIOMessagingPushFCM", ">= 3.13.0"
  
  # Add Firebase dependency - major version 12 up to next major version
  spec.dependency "FirebaseMessaging", "~> 12.0"
end
