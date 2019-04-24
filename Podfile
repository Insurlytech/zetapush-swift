# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '10.0'

inhibit_all_warnings!

target 'ZetaPushSwift' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ZetaPushSwift
  pod 'Starscream', '3.1.0'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'PromiseKit', '~> 6.8'
  pod 'XCGLogger', '~> 7.0'
  pod 'Gloss', '~> 2.1'
end

post_install do |installer|
    
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
        config.build_settings['SWIFT_VERSION'] = '5.0'
    end
    
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
