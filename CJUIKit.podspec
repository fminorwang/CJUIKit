#
# Be sure to run `pod lib lint CJUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CJUIKit"
  s.version          = "0.2.2"
  s.summary          = "CJUIKit."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "for general cj"
  s.homepage         = "https://github.com/fminorwang/CJUIKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "fminor" => "fminor.wang@gmail.com" }
  s.source           = { :git => "https://github.com/fminorwang/CJUIKit.git", :branch => s.version, :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CJUIKit' => ['Pod/Assets/**/*']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation', 'WebKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SDWebImage'
end
