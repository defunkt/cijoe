require 'sinatra'
require 'erb'

dir = File.dirname(File.expand_path(__FILE__))

set :views,  "#{dir}/views"
set :public, "#{dir}/public"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

joe = CIJoe.new(user, project)

get '/' do
  joe.build
  erb(:template, {}, :joe => joe)
end
