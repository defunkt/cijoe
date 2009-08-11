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
require 'cijoe/version'
require 'cijoe/config'
require 'cijoe/commit'
require 'cijoe/build'
require 'cijoe/campfire'
require 'cijoe/server'

class CIJoe
  attr_reader :user, :project, :url, :current_build, :last_build

  def initialize(project_path)
    project_path = File.expand_path(project_path)
    Dir.chdir(project_path)

    @user, @project = git_user_and_project
    @url = "http://github.com/#{@user}/#{@project}"

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
    exit!
  end

  # build callbacks
  def build_failed(output, error)
    finish_build :failed, "#{error}\n\n#{output}"
    run_hook "build-failed"
  end

  def build_worked(output)
    finish_build :worked, output
    run_hook "build-worked"
  end

  def finish_build(status, output)
    @current_build.finished_at = Time.now
    @current_build.status = status
    @current_build.output = output
    @last_build = @current_build
    @current_build = nil
    @last_build.notify if @last_build.respond_to? :notify
  end

  # run the build but make sure only
  # one is running at a time
  def build
    return if building?
    @current_build = Build.new(@user, @project)
    Thread.new { build! }
  end

  # update git then run the build
  def build!
    out, err, status = '', '', nil
    git_update
    @current_build.sha = git_sha

    status = Open4.popen4(runner_command) do |pid, stdin, stdout, stderr|
      @pid = pid
      err, out = stderr.read.strip, stdout.read.strip
    end

    status.exitstatus.to_i == 0 ? build_worked(out) : build_failed(out, err)
  rescue Object => e
    build_failed('', e.to_s)
  end

  # shellin' out
  def runner_command
    runner = Config.cijoe.runner.to_s
    runner == '' ? "rake -s test:units" : runner
  end

  def git_sha
    `git rev-parse origin/#{git_branch}`.chomp
  end

  def git_update
    `git fetch origin && git reset --hard origin/#{git_branch}`
    run_hook "after-reset"
  end

  def git_user_and_project
    Config.remote.origin.url.to_s.chomp('.git').split(':')[-1].split('/')[-2, 2]
  end

  def git_branch
    branch = Config.cijoe.branch.to_s 
    branch == '' ? "master" : branch
  end

  # massage our repo
  def run_hook(hook)
    if File.exists?(file=".git/hooks/#{hook}") && File.executable?(file)
      `sh #{file}`
    end
  end
end
