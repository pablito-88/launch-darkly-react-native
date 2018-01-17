Pod::Spec.new do |s|
  s.name             = "launch-darkly-react-native"
  s.version          = "0.0.11"
  s.summary          = "React Native wrapper for LaunchDarkly"
  s.requires_arc = true
  s.author       = { 'Aurelien Callens' => 'contact@infinitix.io' }
  s.license      = 'MIT'
  s.homepage     = 'n/a'
  s.source       = { :git => "https://github.com/orel91/launch-darkly-react-native.git" }
  s.source_files = 'RNLaunchDarkly/*'
  s.platform     = :ios, "8.0"
  s.dependency 'LaunchDarkly'
  s.dependency 'React'
end