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

require 'sinatra'
require 'open4'
require 'erb'

class CIJoe
  class Build < Struct.new(:started_at, :sha, :finished_at, :status, :output)
    def status
      return super if started_at && finished_at
      :building
    end

    def started_at
      super.strftime(date_format) if super
    end

    def finished_at
      super.strftime(date_format) if super
    end

    def short_sha
      sha[0,7] if sha
    end

    def date_format
      "%Y-%m-%d %H:%M"
    end
  end

  # begin the adventure
  def self.start
    joe = new
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"

    get '/' do
      joe.build
      erb(:template, {}, :joe => joe)
    end
  end

  attr_reader :project, :url, :current_build, :last_build
  def initialize
    @project = "github"
    @url = "http://github.com/defunkt/github"
    @last_build = nil
    @current_build = nil
  end

  # is a build running?
  def building?
    !!@current_build
  end

  # the pid of the running child process
  def pid
    building? and @pid
  end

  # kill the child on exit
  def stop
    Process.kill(9, pid) if pid
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
    out, err = '', ''
    git_update
    @current_build.sha = git_sha

    # don't rebuild the same sha
    if last_build && @current_build.sha == last_build.sha
      @current_build = nil
      return
    end

    Dir.chdir(project) do
      status = Open4.popen4(rake_command) do |@pid, stdin, stdout, stderr|
        err, out = stderr.read.strip, stdout.read.strip
      end
    end

    status.exitstatus.to_i == 0 ? build_worked(out) : build_failed(out, err)
  end

  # shellin' out
  def rake_command
    "rake -s test:units"
  end

  def git_sha
    Dir.chdir project do
      `git rev-parse origin/master`.chomp
    end
  end

  def git_update
    return true
    Dir.chdir project do
      `git fetch origin && git reset --hard origin/master`
    end
  end
end

if $0 == __FILE__
  name_with_owner = ARGV[0]

  if name_with_owner.nil? || !name_with_owner.include?('/')
    puts "Whoops! I need a project name (e.g. mojombo/grit)"
    abort "  $ ruby cijoe.rb project_name"
  else
    user, project = name_with_owner.split('/')
  end

  if !File.exists?(project)
    puts "Whoops! You need to do this first:"
    abort "  $ git clone git@github.com:#{name_with_owner}.git #{project}"
  end

  CIJoe.start(user, project)
end
