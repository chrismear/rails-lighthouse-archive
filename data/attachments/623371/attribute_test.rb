require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/core_ext/class/attribute'

class Klass
  class_attribute :setting
end

class AttributeTest < ActiveSupport::TestCase

  setup do
    @klass = Class.new { class_attribute :setting }
    @klass_two = Klass.new
  end

  test "ActiveSupport/core_ext/class/attribute#class_attribute(*args) defines class method and instance method" do
    assert defined?(@klass.setting)
    assert defined?(@klass_two.setting)
    assert defined?(@klass.class.setting)
    assert defined?(@klass_two.class.setting)
  end

  test "Object#send should behave equally on all classes" do
    assert_equal @klass_two.send(:setting=,1), @klass.send(:setting=,1)
  end

end

