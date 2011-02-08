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

require 'cijoe/version'
require 'cijoe/config'
require 'cijoe/commit'
require 'cijoe/build'
require 'cijoe/campfire'
require 'cijoe/server'

class CIJoe
  attr_reader :user, :project, :url, :current_build, :last_build

  def initialize(project_path)
    @project_path = File.expand_path(project_path)

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
    building? and current_build.pid
  end

  # kill the child and exit
  def stop
    # another build waits
    if !repo_config.buildallfile.to_s.empty? && File.exist?(repo_config.buildallfile.to_s)
      # clean out on stop
      FileUtils.rm(repo_config.buildallfile.to_s)
    end

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
    write_build 'current', @current_build
    write_build 'last', @last_build
    @last_build.notify if @last_build.respond_to? :notify

    # another build waits
    if !repo_config.buildallfile.to_s.empty? && File.exist?(repo_config.buildallfile.to_s)
      # clean out before new build
      FileUtils.rm(repo_config.buildallfile.to_s)
      build
    end
  end

  # run the build but make sure only one is running
  # at a time (if new one comes in we will park it)
  def build(branch=nil)
    if building?
      # only if switched on to build all incoming requests
      if !repo_config.buildallfile.to_s.empty?
        # and there is no previous request
        return if File.exist?(repo_config.buildallfile.to_s)
        # we will mark awaiting builds
        FileUtils.touch(repo_config.buildallfile.to_s)
      end
      # leave anyway because a current build runs
      return
    end
    @current_build = Build.new(@project_path, @user, @project)
    write_build 'current', @current_build
    Thread.new { build!(branch) }
  end

  def open_pipe(cmd)
    read, write = IO.pipe

    pid = fork do
      read.close
      $stdout.reopen write
      exec cmd
    end

    write.close

    yield read, pid
  end

  # update git then run the build
  def build!(branch=nil)
    @git_branch = branch
    build = @current_build
    output = ''
    git_update
    build.sha = git_sha
    build.branch = git_branch
    write_build 'current', build

    open_pipe("cd #{@project_path} && #{runner_command} 2>&1") do |pipe, pid|
      puts "#{Time.now.to_i}: Building #{build.branch} at #{build.short_sha}: pid=#{pid}"

      build.pid = pid
      write_build 'current', build
      output = pipe.read
    end

    Process.waitpid(build.pid, 1)
    status = $?.exitstatus.to_i
    @current_build = build
    puts "#{Time.now.to_i}: Built #{build.short_sha}: status=#{status}"

    status == 0 ? build_worked(output) : build_failed('', output)
  rescue Object => e
    puts "Exception building: #{e.message} (#{e.class})"
    build_failed('', e.to_s)
  end

  # shellin' out
  def runner_command
    runner = repo_config.runner.to_s
    runner == '' ? "rake -s test:units" : runner
  end

  def git_sha
    `cd #{@project_path} && git rev-parse origin/#{git_branch}`.chomp
  end

  def git_update
    `cd #{@project_path} && git fetch origin && git reset --hard origin/#{git_branch}`
    run_hook "after-reset"
  end

  def git_user_and_project
    Config.remote(@project_path).origin.url.to_s.chomp('.git').split(':')[-1].split('/')[-2, 2]
  end

  def git_branch
    return @git_branch if @git_branch
    branch = repo_config.branch.to_s
    @git_branch = branch == '' ? "master" : branch
  end

  # massage our repo
  def run_hook(hook)
    if File.exists?(file=path_in_project(".git/hooks/#{hook}")) && File.executable?(file)
      data =
        if @last_build && @last_build.commit
          {
            "MESSAGE" => @last_build.commit.message,
            "AUTHOR" => @last_build.commit.author,
            "SHA" => @last_build.commit.sha,
            "OUTPUT" => @last_build.env_output
          }
        else
          {}
        end

      ENV.clear
      data.each{ |k, v| ENV[k] = v }
      `cd #{@project_path} && sh #{file}`
    end
  end

  # restore current / last build state from disk.
  def restore
    @last_build = read_build('last')
    @current_build = read_build('current')

    Process.kill(0, @current_build.pid) if @current_build && @current_build.pid
  rescue Errno::ESRCH
    # build pid isn't running anymore. assume previous
    # server died and reset.
    @current_build = nil
  end

  def path_in_project(path)
    File.join(@project_path, path)
  end

  # write build info for build to file.
  def write_build(name, build)
    filename = path_in_project(".git/builds/#{name}")
    Dir.mkdir path_in_project('.git/builds') unless File.directory?(path_in_project('.git/builds'))
    if build
      build.dump filename
    elsif File.exist?(filename)
      File.unlink filename
    end
  end

  def repo_config
    Config.cijoe(@project_path)
  end

  # load build info from file.
  def read_build(name)
    Build.load(path_in_project(".git/builds/#{name}"), @project_path)
  end
end
