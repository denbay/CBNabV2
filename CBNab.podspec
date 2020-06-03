#
# Be sure to run `pod lib lint CBNab.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CBNab'
  s.version          = '0.1.2'
  s.summary          = 'A short description of CBNab.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/denbay/CBNab'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'denbay' => 'dracmor@ya.ru' }
  s.source           = { :git => 'https://github.com/denbay/CBNab.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.description      = <<-DESC
  'DscrollView is an awesome pod aimed to make yor life easier around UIScrollViews.'
                         DESC
  s.swift_version = '5.0'
  s.platforms = {
    "ios": "11.0"
  }
  
  # s.resource_bundles = {
  #   'CBNab' => ['CBNab/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit', '~> 5.0.0'

end
