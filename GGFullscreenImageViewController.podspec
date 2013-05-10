Pod::Spec.new do |s|
  s.platform = :ios
  s.name = "GGFullscreenImageViewController"
  s.version = "1.0.0"
  s.summary = "Let's you fullscreen any UIImageView"
  s.author = {
    'John Z Wu' => 'bogardon@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/bONchON/GGFullscreenImageViewController.git',
    :tag => 'v1.0.0'
  }
  s.source_files = 'GGFullscreenImageViewController/GGFullscreenImageViewController.{h,m}'
  s.requires_arc = true
end
