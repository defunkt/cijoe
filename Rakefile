desc "Build a gem"
task :gem => [ :gemspec, :build ]

begin
  require 'jeweler'

  $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
  require 'cijoe/version'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cijoe"
    gemspec.summary = "CI Joe is a simple Continuous Integration server."
    gemspec.description = "CI Joe is a simple Continuous Integration server."
    gemspec.email = "chris@ozmm.org"
    gemspec.homepage = "http://github.com/defunkt/cijoe"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.add_dependency 'choice'
    gemspec.add_dependency 'sinatra'
    gemspec.version = CIJoe::Version.to_s
  end
rescue LoadError
  puts "Jeweler not available." 
  puts "Install it with: gem install jeweler"
end
