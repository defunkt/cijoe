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
    # make Build#restore a no-op so we don't overwrite our current/last
    # build attributes set from tests.
    joe = @app.joe
    def joe.restore
    end
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

  def test_ping_building_with_a_previous_build
    app.joe.last_build = build :worked
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

  def test_ping_should_not_reset_current_build_in_tests
    current_build = build :building
    app.joe.current_build = current_build
    assert app.joe.building?
    get "/ping"
    assert_equal current_build, app.joe.current_build
  end

  def test_jsonp_should_return_plain_json_without_param
    app.joe.last_build = build :failed
    get "/api/json"
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.content_type
  end

  def test_jsonp_should_return_jsonp_with_param
    app.joe.last_build = build :failed
    get "/api/json?jsonp=fooberz"
    puts last_response.inspect
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert_match /^fooberz\(/, last_response.body 

  end

  def test_should_not_barf_when_no_build
  end

  # Create a new, fake build. All we care about is status.

  def build status
    CIJoe::Build.new "path", "user", "project", Time.now, Time.now,
      "deadbeef", status, "output", nil
  end
end
