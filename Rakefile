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

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "someproject #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
