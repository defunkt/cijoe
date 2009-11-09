require 'helper'

class TestCIJoe < Test::Unit::TestCase
  def test_raise_error_on_invalid_command
    assert_raise RuntimeError, LoadError do
      CIJoe::Config.new('--invalid').to_s
    end
  end
  
  def test_return_value_of_config
    assert_equal `git config blame`.chomp, CIJoe::Config.new('blame').to_s
  end
  
  def test_return_empty_string_when_config_does_not_exist
    assert_equal '', CIJoe::Config.new('invalid').to_s
  end
end
