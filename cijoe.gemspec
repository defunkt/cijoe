$LOAD_PATH.unshift 'lib'
require "cijoe/version"

Gem::Specification.new do |s|
  s.name              = "cijoe"
  s.version           = CIJoe::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "cijoe builds your builds."
  s.homepage          = "http://github.com/defunkt/cijoe"
  s.email             = "chris@ozmm.org"
  s.authors           = [ "Chris Wanstrath" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

  s.executables       = %w( cijoe )

  s.add_runtime_dependency     'choice'
  s.add_runtime_dependency     'sinatra'
  s.add_development_dependency 'rack-test'

   s.description       = <<desc
  cijoe is a sinatra-based continuous integration server. It's like an
  old rusty pickup truck: it might be smelly and gross, but it gets the
  job done.
desc
end
