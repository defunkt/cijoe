# Example CI Joe rackup config. Drop a cijoe.ru file
# in your projects direct
require 'cijoe'

# setup middleware
use Rack::CommonLogger

# configure joe
CIJoe::Server.configure do |config|
  config.set :project_path, File.dirname(__FILE__)
  config.set :show_exceptions, true
  config.set :lock, true
end

run CIJoe::Server
