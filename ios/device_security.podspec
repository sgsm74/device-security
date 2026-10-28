Pod::Spec.new do |s|
  s.name             = 'device_security'
  s.version          = '1.0.0'
  s.summary          = 'Root/jailbreak, emulator and USB debugging detection.'
  s.description      = 'Native device integrity checks for Flutter apps.'
  s.homepage         = 'https://sevensoft.ir'
  s.license          = { :type => 'Proprietary', :file => '../LICENSE' }
  s.author           = { 'SevenSoft' => 'info@sevensoft.ir' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {'device_security_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
