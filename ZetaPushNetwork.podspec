#
#  Be sure to run `pod spec lint ZetaPushNetwork.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ZetaPushNetwork"
  spec.version      = "3.1.1"
  spec.summary      = "Swift client for ZetaPush"
  spec.description  = <<-DESC
  Swift client for ZetaPush
  Allows dev to easily connect to ZetaPush Backend As A Service
                   DESC
  spec.homepage     = "http://zetapush.com"
  spec.license      = "Leocare"
  spec.author       = { "Anthony GUIGUEN" => "anthony@insurlytech.com" }

  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/Insurlytech/zetapush-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.{swift}"
  spec.exclude_files = "Classes/Exclude"

  spec.framework  = "UIKit", "Foundation"
  spec.requires_arc = true

  spec.dependency "PromiseKit", "~> 6.13"
  spec.dependency "Gloss", "~> 3.0"
  spec.dependency "CometDClient", "~> 1.1.0"
end
