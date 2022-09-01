require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'Expo'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '12.0'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.static_framework = true
  s.header_dir     = 'Expo'

  s.dependency 'ExpoModulesCore'

  s.source_files = 'ios/**/*.{h,m,swift}'


  ex_updates_native_debug = ENV['EX_UPDATES_NATIVE_DEBUG'] == '1'
  if ex_updates_native_debug
    s.pod_target_xcconfig = {
      'OTHER_CFLAGS[config=Debug]' => "$(inherited) -DEX_UPDATES_NATIVE_DEBUG=1"
    }
  end  
end
