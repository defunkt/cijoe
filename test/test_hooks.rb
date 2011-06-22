require 'helper'

# mock files to true
class File
  class << self
    alias orig_exists? exists?
    alias orig_executable? executable?
    
    def exists?(f)
      return true if $hook_override
      orig_exists? f
    end
    def executable?(f)
      return true if $hook_override
      orig_executable? f
    end
  end
end

# #mock file to be the file I want
class CIJoe
  attr_writer :last_build
  alias orig_path_in_project path_in_project
  alias orig_git_user_and_project git_user_and_project
  
  def path_in_project(f)
    return '/tmp/test' if $hook_override
    orig_path_in_project
  end
  
  def git_user_and_project
    return ['mine','yours'] if $hook_override
    orig_git_user_and_project
  end
end

class CIJoe::Commit
  attr_writer :raw_commit
end



class TestHooks < Test::Unit::TestCase
  def teardown
    $hook_override = nil
  end
  
  def setup
    $hook_override = true
    open("/tmp/test",'w') do |file|
      file.write "echo $test\n"
      file.write "echo $AUTHOR\n"
      file.write "export test=foo\n"
    end
    File.chmod(0777,'/tmp/test')
    
    @cijoe = CIJoe.new('/tmp')
    @cijoe.last_build = CIJoe::Build.new "path", "user", "project", Time.now, Time.now,
      "deadbeef", :failed, "output", nil
    @cijoe.last_build.commit.raw_commit = "Author: commit author\nDate: now"
  end
  
  def test_leave_env_intact
    ENV['AUTHOR'] = 'foo'
    @cijoe.run_hook("/tmp/test")
    assert ENV.size != 0, 'ENV is empty but should not be'
    assert ENV['AUTHOR'] == 'foo', 'ENV munged a value'
  end
  
  def test_empty_hook_env
    ENV["test"] = 'should not be shown'
    output = @cijoe.run_hook("/tmp/test")
    assert_equal "\ncommit author\n", output
  end
  
  def test_hook_munge_env
    ENV['test'] = 'bar'
    output = @cijoe.run_hook("/tmp/test")
    assert ENV['test'] == 'bar'
  end
end