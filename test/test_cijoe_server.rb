require "helper"
require "rack/test"
require "cijoe/server"

class TestCIJoeServer < Test::Unit::TestCase
  include Rack::Test::Methods

  class ::CIJoe
    attr_writer :current_build, :last_build
  end

  attr_accessor :app

  def setup
    @app = CIJoe::Server.new
  end

  def test_ping
    app.joe.last_build = build :worked
    assert !app.joe.building?, "have a last build, but not a current"

    get "/ping"
    assert_equal 200, last_response.status
    assert_equal app.joe.last_build.sha, last_response.body
  end

  def test_ping_building
    app.joe.current_build = build :building
    assert app.joe.building?, "buildin' a awsum project"

    get "/ping"
    assert_equal 412, last_response.status
    assert_equal "building", last_response.body
  end

  def test_ping_failed
    app.joe.last_build = build :failed

    get "/ping"
    assert_equal 412, last_response.status
    assert_equal app.joe.last_build.sha, last_response.body
  end

  # Create a new, fake build. All we care about is status.

  def build status
    CIJoe::Build.new "user", "project", Time.now, Time.now,
      "deadbeef", status, "output", 1337
  end
end
