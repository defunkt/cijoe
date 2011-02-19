require "helper"
require "cijoe"
require "fakefs/safe"


class TestCampfire < Test::Unit::TestCase

  class ::CIJoe
    attr_writer :current_build, :last_build
  end

  attr_accessor :app

  def setup
    @app = CIJoe::Server.new
    joe = @app.joe
    
    # make Build#restore a no-op so we don't overwrite our current/last
    # build attributes set from tests.
    def joe.restore
    end
    
    # make CIJoe#build! and CIJoe#git_update a no-op so we don't overwrite our local changes
    # or local commits nor should we run tests.
    def joe.build!
    end
  end
  
  def teardown
    teardown_git_info
  end
  
  def test_campfire_pulls_campfire_config_from_git_config
    setup_git_info(:config => {"campfire.subdomain" => "github", "remote.origin.url" => "https://github.com/defunkt/cijoe.git"})
    cf = CIJoe::Campfire.new(tmp_dir)
    assert_equal "github", cf.campfire_config[:subdomain]
  end
  
  def test_campfire_pulls_campfire_config_from_its_own_git_config
    setup_git_info(:config => {"campfire.subdomain" => "github"})
    setup_git_info(:config => {"campfire.subdomain" => "37signals"}, :tmp_dir => "/tmp/cijoe_test_37signals")
    cf1 = CIJoe::Campfire.new(tmp_dir)
    cf2 = CIJoe::Campfire.new("/tmp/cijoe_test_37signals")
    assert_equal "github", cf1.campfire_config[:subdomain]
    assert_equal "37signals", cf2.campfire_config[:subdomain]
  end
  
end