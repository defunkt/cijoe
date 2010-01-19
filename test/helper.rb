require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cijoe'

CIJoe::Server.set :project_path, "."
CIJoe::Server.set :environment,  "test"

class Test::Unit::TestCase
end
