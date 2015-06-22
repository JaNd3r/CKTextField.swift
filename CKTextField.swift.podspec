
Pod::Spec.new do |s|

  s.name         = "CKTextField.swift"
  s.version      = "0.1.0"
  s.summary      = "An improved version of the original UITextField."

  s.description  = <<-DESC
                   CKTextField was started as an enhanced UITextField which
                   uses subtle animations to add to a better user
                   experience.
                   DESC

  s.homepage     = "https://github.com/JaNd3r/CKTextField.swift"
  s.screenshots  = "https://raw.githubusercontent.com/JaNd3r/CKTextField.swift/master/CKTextFieldDemo.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Christian Klaproth" => "ck@cm-works.de" }
  s.social_media_url   = "http://twitter.com/JaNd3r"

  s.platform     = :ios, "8.3"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/JaNd3r/CKTextField.swift.git", :tag => "0.1.0" }

  s.source_files  = "CKTextField/*.swift"

end
