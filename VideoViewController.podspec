Pod::Spec.new do |spec|
  spec.name         = "VideoViewController"
  spec.version      = "1.1"
  spec.authors      = { "Danil Gontovnik" => "gontovnik.danil@gmail.com" }
  spec.homepage     = "https://github.com/gontovnik/Periscope-VideoViewController"
  spec.summary      = "Video view controller with Periscope fast rewind control"
  spec.source       = { :git => "https://github.com/gontovnik/Periscope-VideoViewController.git", :tag => '1.1' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.platform     = :ios, '8.0'
  spec.source_files = "VideoViewController/*.swift"

  spec.requires_arc = true

  spec.ios.deployment_target = '8.0'
  spec.ios.frameworks = ['UIKit', 'AVFoundation']
end
