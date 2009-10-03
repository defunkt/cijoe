begin
  require 'jeweler'

  # We're not putting VERSION or VERSION.yml in the root,
  # so we have to help Jeweler find our version.
  $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
  require 'cijoe/version'

  CIJoe::Version.instance_eval do
    def refresh
    end
  end

  class Jeweler
    def version_helper
      CIJoe::Version
    end

    def version_exists?
      true
    end
  end

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cijoe"
    gemspec.summary = "CI Joe is a simple Continuous Integration server."
    gemspec.description = "CI Joe is a simple Continuous Integration server."
    gemspec.email = "chris@ozmm.org"
    gemspec.homepage = "http://github.com/defunkt/cijoe"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.add_dependency 'choice'
    gemspec.add_dependency 'sinatra'
    gemspec.add_dependency 'open4'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
