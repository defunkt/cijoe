require 'sinatra'
require 'erb'

class CIJoe
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"
    set :static, true

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
    end

    def self.start(host, port, project_path)
      check_project(project_path)

      joe = CIJoe.new(project_path)
      get '/' do
        erb(:template, {}, :joe => joe)
      end

      post '/' do
        joe.build
        redirect '/'
      end

      CIJoe::Campfire.activate
      CIJoe::Server.run! :host => host, :port => port
    end

    def self.check_project(project)
      if project.nil? || !File.exists?(project)
        puts "Whoops! I need the path to a Git repo."
        puts "  $ git clone git@github.com:username/project.git project"
        abort "  $ cijoe project"
      end
    end
  end
end
