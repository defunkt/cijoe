require 'rubygems'
require 'test/unit'
require 'mocha'

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cijoe'

CIJoe::Server.set :project_path, "."
CIJoe::Server.set :environment,  "test"

TMP_DIR = '/tmp/cijoe_test'

def tmp_dir
  TMP_DIR
end

def setup_git_info(options = {})
  @tmp_dirs ||= []
  @tmp_dirs += [options[:tmp_dir]]
  create_tmpdir!(options[:tmp_dir])
  dir = options[:tmp_dir] || tmp_dir
  `cd #{dir} && git init`
  options[:config].each do |key, value|
    `cd #{dir} && git config --add #{key} "#{value}"`
  end
end

def teardown_git_info
  remove_tmpdir!
  @tmp_dirs.each do |dir|
    remove_tmpdir!(dir)
  end
end

def remove_tmpdir!(passed_dir = nil)
  FileUtils.rm_rf(passed_dir || tmp_dir)
end

def create_tmpdir!(passed_dir = nil)
  FileUtils.mkdir_p(passed_dir || tmp_dir)
end

class Test::Unit::TestCase
end
