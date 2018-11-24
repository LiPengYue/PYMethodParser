

Pod::Spec.new do |s|
  s.name             = 'PYMethodParser'
  s.version          = '0.1.0'
  s.summary          = '关于方法动态调用的工具'



  s.description      = <<-DESC
关于方法动态调用的工具
                       DESC

  s.homepage         = 'https://github.com/LiPengYue/PYMethodParser'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LiPengYue' => '702029772@qq.com' }
  s.source           = { :git => 'https://github.com/LiPengYue/PYMethodParser.git', :tag => s.version.to_s, :submodules => true }


  s.ios.deployment_target = '8.0'

  s.source_files = 'PYMethodParser/Classes/**/*'
  


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
