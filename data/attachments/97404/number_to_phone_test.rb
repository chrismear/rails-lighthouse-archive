require 'rubygems'
require 'test/unit'
require 'actionpack'
require 'action_view'

class NumberToPhoneTest < Test::Unit::TestCase
  def setup
    @helpers = ActionView::Base.new
  end
  
  # passes
  def test_number_to_phone_should_work_with_nine_digits
    assert_equal '800-555-1234', @helpers.number_to_phone(8005551234)
  end
  
  # fails
  def test_number_to_phone_should_work_with_seven_digits
    assert_equal '555-1234', @helpers.number_to_phone(5551234)
  end
end