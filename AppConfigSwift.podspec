#
# Be sure to run `pod lib lint AppConfigSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppConfigSwift'
  s.version          = '0.7.0'
  s.summary          = 'A useful library to support multiple build configurations in one application build.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A useful library to support multiple build configurations in one application build.
For example: be able to make one build with a build selector that contains development, test, acceptance and a production configuration. There would be no need to deliver multiple builds for each environment for testing, it can all be done from one build.
                       DESC

  s.homepage         = 'https://github.com/crescentflare/AppConfigSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Crescent Flare' => 'info@crescentflare.com' }
  s.source           = { :git => 'https://github.com/crescentflare/AppConfigSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AppConfigSwift/Classes/**/*'
  
  s.resource_bundles = {
    'AppConfigSwift' => ['AppConfigSwift/Localization/*.lproj', 'AppConfigSwift/Layout/*.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
