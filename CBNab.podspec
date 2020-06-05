Pod::Spec.new do |s|
  s.name             = 'CBNab'
  s.version          = '0.2.0'
  s.summary          = 'Awesome lib.'

  s.description      = <<-DESC
  'Awesome lib.'
                         DESC

  s.homepage         = 'https://github.com/denbay/CBNab'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'denbay' => 'dracmor@ya.ru' }
  s.source           = { :git => 'https://github.com/denbay/CBNab.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.description      = <<-DESC
  'DscrollView is an awesome pod aimed to make yor life easier around UIScrollViews.'
                         DESC
                         
  s.source_files = 'Source/**/*.swift'
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
  s.dependency 'FacebookSDK'
  s.dependency 'Branch'
  s.dependency 'Moya'
  s.dependency 'SwiftyStoreKit'

end
