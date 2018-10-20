Pod::Spec.new do |s|
s.name        = "JSONMatching"
s.version     = "1.0.2"
s.summary     = "JSONMatching provide an easy way to decode JSON data into Model object in Swift"
s.homepage    = "https://github.com/SiriDx/JSONMatching"
s.license     = { :type => "MIT" }
s.authors     = { "DeanChen" => "dxchen321@gmail.com" }
s.requires_arc = true

s.platform     = :ios, '8.0'
s.ios.deployment_target = "8.0"
s.source   = { :git => "https://github.com/SiriDx/JSONMatching.git", :tag => s.version }
s.source_files = "Source/*.swift"
end
