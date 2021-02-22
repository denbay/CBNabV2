target 'CBNab_Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Moya'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'SwiftyStoreKit'
  pod 'AppsFlyerFramework'
  pod 'KeychainSwift', '~> 19.0'
  pod 'SVProgressHUD'
  pod 'ApphudSDK'
  
  post_install do |installer| installer.pods_project.targets.each do |target| target.build_configurations.each do |config| config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64' end end end
  
end
