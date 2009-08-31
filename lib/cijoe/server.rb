require 'sinatra'
require 'erb'

class CIJoe
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"
    set :static, true

    get '/?' do
      erb(:template, {}, :joe => @joe)
    end

    post '/?' do
      payload = params[:payload].to_s
      if payload.empty? || payload.include?(@joe.git_branch)
        @joe.build
      end
      redirect request.path
    end


    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      # thanks integrity!
      def bash_color_codes(string)
        string.gsub("\e[0m", '</span>').
          gsub("\e[31m", '<span class="color31">').
          gsub("\e[32m", '<span class="color32">').
          gsub("\e[33m", '<span class="color33">').
          gsub("\e[34m", '<span class="color34">').
          gsub("\e[35m", '<span class="color35">').
          gsub("\e[36m", '<span class="color36">').
          gsub("\e[37m", '<span class="color37">')
      end

      def pretty_time(time)
        time.strftime("%Y-%m-%d %H:%M")
      end
    end

    def initialize(*args)
      super
      @joe = CIJoe.new(options.project_path)
      check_project
      setup_auth

      CIJoe::Campfire.activate
    end

    def self.start(host, port, project_path)
      set :project_path, project_path
      CIJoe::Server.run! :host => host, :port => port
    end

    def check_project
      if options.project_path.nil? || !File.exists?(options.project_path)
        puts "Whoops! I need the path to a Git repo."
        puts "  $ git clone git@github.com:username/project.git project"
        abort "  $ cijoe project"
      end
    end

    def setup_auth
      user, pass = Config.cijoe.user.to_s, Config.cijoe.pass.to_s

      if user != '' && pass != ''
        use Rack::Auth::Basic do |username, password|
          [ username, password ] == [ user, pass ]
        end
        puts "Using HTTP basic auth"
      end
    end
  end
end
