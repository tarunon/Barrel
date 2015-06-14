Pod::Spec.new do |s|
    s.name         = "Barrel"
    s.version      = "0.3.0"
    s.summary      = "Type safe CoreData library."
    s.license      = { :type => 'MIT', :file => './LICENSE' }
    s.homepage     = "https://github.com/tarunon/Barrel"
    s.source       = { :git => 'https://github.com/tarunon/Barrel.git', :branch => 'swift2.0'}
    s.author       = { "tarunon" => "croissant9603[at]gmail.com" }
    s.source_files = 'Barrel/*.{swift,h}'
    s.platform     = :ios, '8.0'
    s.requires_arc = true
    s.frameworks   = 'CoreData'
end
