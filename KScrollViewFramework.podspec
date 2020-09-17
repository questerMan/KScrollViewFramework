Pod::Spec.new do |spec|
  spec.name         = "KScrollViewFramework"
  spec.version      = "1.0.0"
  spec.summary      = "滚动展示视图"
  spec.description  = <<-DESC
  
  代码语言：Swift；使用链式编程思想封装的滚动展示视图，让代码看起来更加优雅。
                   DESC
  spec.homepage     = "https://github.com/questerMan/KScrollViewFramework.git"
  spec.license      = "MIT"
  spec.ios.deployment_target = '13.0'
  spec.author             = { "疯狂1024" => "luyikun01@163.com" }
  spec.source       = { :git => "https://github.com/questerMan/KScrollViewFramework.git", :tag => "#{spec.version}" }
  spec.source_files  = "KScrollViewFramework", "KScrollViewFramework/KScrollViewFramework/KScrollview/**/*.{swift}"
  spec.swift_version = '5.0'
end
