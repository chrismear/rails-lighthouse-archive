require 'rubygems'
require 'test/unit'
require 'action_view'
require 'active_support/core_ext'

class NumberToPhoneTest < Test::Unit::TestCase
  def setup
    @helpers = ActionView::Base.new
  end

  # passes
  def test_number_to_phone_should_work_with_seven_digits
    assert_equal("555-1234", @helpers.number_to_phone(5551234))
  end


  def test_number_to_phone_should_work_with_ten_digits_and_area_code
    assert_equal("(800) 555-1212", @helpers.number_to_phone(8005551212, {:area_code => true}))
  end

  # fails
  def test_number_to_phone_should_work_with_seven_digits_and_area_code
    assert_equal("555-1234", @helpers.number_to_phone(5551234, {:area_code => true}))
  end
end