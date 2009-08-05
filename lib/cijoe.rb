##
# CI Joe.
# Because knowing is half the battle.
#
# This is a stupid simple CI server. It can build one (1)
# git-based project only.
#
# It only remembers the last build.
#
# It only notifies to Campfire.
#
# It's a RAH (Real American Hero).
#
# Seriously, I'm gonna be nuts about keeping this simple.

require 'open4'
require 'cijoe/build'
require 'cijoe/campfire'
require 'cijoe/server'

class CIJoe
  attr_reader :user, :project, :url, :current_build, :last_build
  def initialize(user, project)
    @user = user
    @project = project
    @url = "http://github.com/#{user}/#{project}"
    @last_build = nil
    @current_build = nil
    trap("INT") { stop }
  end

  # is a build running?
  def building?
    !!@current_build
  end

  # the pid of the running child process
  def pid
    building? and @pid
  end

  # kill the child and exit
  def stop
    Process.kill(9, pid) if pid
    raise Interrupt
  end

  # build callbacks
  def build_failed(output, error)
    finish_build :failed, "#{error}\n\n#{output}"
  end

  def build_worked(output)
    finish_build :worked, output
  end

  def finish_build(status, output)
    @current_build.finished_at = Time.now
    @current_build.status = status
    @current_build.output = output
    @last_build = @current_build
    @current_build = nil
  end

  # run the build but make sure only
  # one is running at a time
  def build
    return @current_build if building?
    @current_build = Build.new(Time.now)
    Thread.new { build! }
  end

  # update git then run the build
  def build!
    Dir.chdir(Dir.pwd + '/' + project)

    out, err, status = '', '', nil
    git_update
    @current_build.sha = git_sha

    # don't rebuild the same sha
    if last_build && @current_build.sha == last_build.sha
      @current_build = nil
      return
    end

    status = Open4.popen4(rake_command) do |@pid, stdin, stdout, stderr|
      err, out = stderr.read.strip, stdout.read.strip
    end

    status.exitstatus.to_i == 0 ? build_worked(out) : build_failed(out, err)
  rescue Object => e
    build_failed('', e.to_s)
  end

  # shellin' out
  def rake_command
    "rake -s test:units"
  end

  def git_sha
    `git rev-parse origin/master`.chomp
  end

  def git_update
    `git fetch origin && git reset --hard origin/master`
  end
end
