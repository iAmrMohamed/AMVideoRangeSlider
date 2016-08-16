Pod::Spec.new do |s|

  s.name         = "AMVideoRangeSlider"
  s.version      = "1.0.0"
  s.summary      = "iOS Video Range Slider in Swift"

  s.homepage     = "https://github.com/iAmrMohamed/AMVideoRangeSlider"

  s.license      = "MIT"

  s.author             = { "Amr Mohamed" => "iAmrMohamed@gmail.com" }
  s.social_media_url   = "https://twitter.com/iAmrMohamed"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/iAmrMohamed/AMVideoRangeSlider.git", :tag => s.version }

  s.source_files  = "AMVideoRangeSlider/*.swift"

  s.frameworks = "UIKit"

  s.requires_arc = true

end
