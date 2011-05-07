require File.dirname(__FILE__) + '/../test_helper'

ActiveRecord::Schema.define do
  create_table :parents, :force => true do |t|
  end

  create_table :children, :force => true do |t|
    t.integer :parent_id
  end
end

class InBeforeValidation < StandardError; end

class Parent < ActiveRecord::Base
  has_one :child

  before_create do |model|
    model.build_child
  end
end

class Child < ActiveRecord::Base
  belongs_to :parent

  before_validation do |model|
    raise InBeforeValidation
  end
end

class HasOneCallbackTest < ActiveSupport::TestCase
  test "The child's before_validation callback is invoked when created and saved by the parent" do
    assert_raise InBeforeValidation do
      Parent.create
    end
  end
end