#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_admob_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_admob_flutter'
  s.version          = '0.4.1'
  s.summary          = 'Native AdMOB.'
  s.description      = <<-DESC
A flutter plugin to help you implement AdMOB ads easily
                       DESC
  s.homepage         = 'https://github.com/bdlukaa/native_admob_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'bdlukaa' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
