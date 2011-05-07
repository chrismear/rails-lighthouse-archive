require File.dirname(__FILE__) + '/../spec_helper'

class TestNamedScope < ActiveRecord::Base
  named_scope :public
  
  private
  def private_method
  end
  
  public
  def public_method
  end
end

describe TestNamedScope do
  it "should have public method as a public method" do
    TestNamedScope.public_instance_methods.should include("public_method")
  end
end