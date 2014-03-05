Pod::Spec.new do |s|
  s.name         = "NewsletterLibrary"
  s.version      = "0.3"
  s.summary      = "Newsletter extension library for ZulaMobile"

  s.description  = <<-DESC
                    Newsletter extension library for ZulaMobile
                   DESC

  s.homepage     = "http://www.zulamobile.com"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Suleyman Melikoglu" => "suleymanmelikoglu@gmail.com"}
  s.platform     = :ios, '6.0'
  s.source       = { :git => "solomon@melikoglu.info:zula_newsstand_library.git" }
  s.source_files  = 'NewsstandLibrary/Classes/**/**/**/**/**/*.{h,m}'
  #s.exclude_files = 'Classes/Exclude'
  #s.resources = "RoboReader/Graphics/*.png"
  s.requires_arc = true
end
