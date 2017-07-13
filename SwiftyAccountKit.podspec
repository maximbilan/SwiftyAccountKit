Pod::Spec.new do |s|
s.name         = "SwiftyAccountKit"
s.version      = "0.1.0"
s.summary      = "AccountKit wrapper by Swift"
s.description  = "Wrapper for Facebook AccountKit framework"
s.homepage     = "https://github.com/maximbilan/SwiftyAccountKit"
s.license      = { :type => "MIT" }
s.author       = { "Maxim Bilan" => "maximb.mail@gmail.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/maximbilan/SwiftyAccountKit.git", :tag => "0.1.0" }
s.source_files = "Classes", "SwiftyAccountKit/Sources/**/*.{swift}"
s.dependency "AccountKit"
s.requires_arc = true
end