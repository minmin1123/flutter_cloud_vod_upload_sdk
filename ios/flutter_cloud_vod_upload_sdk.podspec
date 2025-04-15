#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tencent_flutter_cloud_vod_upload_sdk.podspec' to validate before publishing.
# 插件 flutter部分参考 https://git.woa.com/FlutterEcology/tencent_flutter_cloud_vod_upload_sdk
# 插件 native SDK部分参考 https://cloud.tencent.com/document/product/266/13793
Pod::Spec.new do |s|
  s.name             = 'flutter_cloud_vod_upload_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
#   s.public_header_files = ['Classes/**/*.h']
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.static_framework = true
  s.vendored_libraries = 'lib/*.a'
  s.libraries = [
     "stdc++",
   ]
  s.subspec "TXUGCUpload" do |spec|
     spec.source_files = 'TXUGCUpload/**/*.h'
     spec.dependency 'AFNetworking', '4.0.1.0.1'
   end
  s.vendored_frameworks = 'Framework/*.framework'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end