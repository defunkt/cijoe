require 'helper'

class TestCIJoeQueue < Test::Unit::TestCase
  def test_a_disabled_queue
    subject = CIJoe::Queue.new(false)
    subject.append_unless_already_exists("test")
    assert_equal false, subject.waiting?
  end

  def test_adding_two_items_to_a_queue
    subject = CIJoe::Queue.new(true)
    subject.append_unless_already_exists("test")
    subject.append_unless_already_exists(nil)
    assert_equal true, subject.waiting?
    assert_equal "test", subject.next_branch_to_build
    assert_equal nil, subject.next_branch_to_build
    assert_equal false, subject.waiting?
  end

  def test_adding_two_duplicate_items_to_a_queue
    subject = CIJoe::Queue.new(true)
    subject.append_unless_already_exists("test")
    subject.append_unless_already_exists("test")
    assert_equal true, subject.waiting?
    assert_equal "test", subject.next_branch_to_build
    assert_equal false, subject.waiting?
  end
end
