require "rubygems"
require "uninclude"

module Core
  def save; "saved" end
end

module Dirty
  def save; "clean + " + super end
end

module Transaction  
  def save; "transaction + " + super end
end

module Validation
  def save;  "valid + " + super end
end

class Base
  include Core
  include Dirty
  include Transaction
  include Validation
end

# PLUGIN adding more validation
module MyValidation
  def save
    "more validation + " + super
  end
end

# PLUGIN overiding Transaction
module MyTransaction  
  def save 
    Base.send :uninclude, Transaction
    body = super + " + my transaction!"
    Base.send :include, Transaction
    body
  end
end

# Our everyday model
class A < Base
  include MyTransaction
end

class B < Base; end

class C < Base
  include MyValidation
end

a = A.new      
b = B.new
c = C.new
puts a.save #=> 
puts b.save #=> 
puts c.save #=> 

p A.ancestors
p B.ancestors
p C.ancestors


