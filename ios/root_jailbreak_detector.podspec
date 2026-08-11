#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint root_jailbreak_detector.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'root_jailbreak_detector'
  s.version          = '1.0.0'
  s.summary          = 'Root and jailbreak detection for Flutter apps.'
  s.description      = <<-DESC
Detects whether the current device is rooted (Android) or jailbroken (iOS),
so your app can react to running on a device whose integrity it cannot trust.
                       DESC
  s.homepage         = 'https://github.com/ozanorfa/root_jailbreak_detector'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ozan Orfa' => 'ozanorfa.dev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'root_jailbreak_detector/Sources/root_jailbreak_detector/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {
    'root_jailbreak_detector_privacy' => ['root_jailbreak_detector/Sources/root_jailbreak_detector/PrivacyInfo.xcprivacy']
  }
end
