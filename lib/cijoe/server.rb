require 'sinatra/base'
require 'erb'

class CIJoe
  class Server < Sinatra::Base
    attr_reader :joe

    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"
    set :static, true
    set :lock, true

    before { joe.restore }

    get '/ping' do
      if joe.building? || !joe.last_build || !joe.last_build.worked?
        halt 412, joe.last_build ? joe.last_build.sha : "building"
      end

      joe.last_build.sha
    end

    get '/?' do
      erb(:template, {}, :joe => joe)
    end

    post '/?' do
      payload = params[:payload].to_s
      if payload.empty? || payload.include?(joe.git_branch)
        joe.build
      end
      redirect request.path
    end

    user, pass = Config.cijoe.user.to_s, Config.cijoe.pass.to_s
    if user != '' && pass != ''
      use Rack::Auth::Basic do |username, password|
        [ username, password ] == [ user, pass ]
      end
      puts "Using HTTP basic auth"
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      # thanks integrity!
      def ansi_color_codes(string)
        string.gsub("\e[0m", '</span>').
          gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
      end

      def pretty_time(time)
        time.strftime("%Y-%m-%d %H:%M")
      end

      def cijoe_root
        root = request.path
        root = "" if root == "/"
        root
      end
    end

    def initialize(*args)
      super
      check_project
      @joe = CIJoe.new(options.project_path)

      CIJoe::Campfire.activate
    end

    def self.start(host, port, project_path)
      set :project_path, project_path
      CIJoe::Server.run! :host => host, :port => port
    end

    def check_project
      if options.project_path.nil? || !File.exists?(File.expand_path(options.project_path))
        puts "Whoops! I need the path to a Git repo."
        puts "  $ git clone git@github.com:username/project.git project"
        abort "  $ cijoe project"
      end
    end
  end
end
