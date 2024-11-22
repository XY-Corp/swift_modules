#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mobility_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mobility_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for mobility data.'
  s.description      = <<-DESC
                           A Flutter plugin to access mobility data like walking speed from Apple HealthKit.
                       DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.swift_version = '5.0'
end
