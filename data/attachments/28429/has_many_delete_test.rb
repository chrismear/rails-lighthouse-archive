require 'test/unit'

require 'rubygems'
require 'activerecord'

#set rails env CONSTANT (we are not actually loading rails in this test, but activerecord depends on this constant)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)

# RAILS_GEM_VERSION = '2.1'
# RAILS_GEM_VERSION = '2.0.2'
# RAILS_GEM_VERSION = '1.99.0'
# RAILS_GEM_VERSION = '1.2.6'
# RAILS_GEM_VERSION = '1.2.2'

#setup active record to use a sqlite database
# ActiveRecord::Base.configurations = {"test"=>{"dbfile"=>"test.db", "adapter"=>"sqlite3"}}
# ActiveRecord::Base.establish_connection
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

#load the database schema for this test
ActiveRecord::Schema.define do
  create_table "cars", :force => true do |t|
    t.integer  "driver_id"
    t.string   "name"
  end
  create_table "drivers", :force => true do |t|
    t.string   "name"
  end
end

#models
class Car < ActiveRecord::Base
  belongs_to :driver
end

class Driver < ActiveRecord::Base
  has_many :cars
  validate do |driver|
    if driver.cars.empty?
      driver.errors.add("Drivers must have at least one car")
    end
  end
end

class HasManyDeleteTest < Test::Unit::TestCase
  
  def test_where_i_workaround_the_issue
    bug = Car.create(:name => "Bug")
    bob = Driver.create(:name => "Bob", :cars => [bug])

    bug.reload
    bob.reload

    assert bob.valid?, "Models were just created, driver model should be valid at this point"
    
    carsarr = bob.cars.to_a
    carsarr.delete(bug)
    bob.cars = carsarr

    assert !bob.valid?, "Bob just lost his car, driver model should no longer be valid"
    
    bob.reload
    bug.reload

    assert bob.valid?, "We never 'saved' that bob lost his car.. so if we reload the data, the driver model should be valid again, right?"    
  end
  
  def test_where_i_encountered_the_issue
    bug = Car.create(:name => "Bug")
    bob = Driver.create(:name => "Bob", :cars => [bug])

    bug.reload
    bob.reload

    assert bob.valid?, "Models were just created, driver model should be valid at this point"
        
    bob.cars.delete(bug)

    assert !bob.valid?, "Bob just lost his car, driver model should no longer be valid"
    
    bob.reload
    bug.reload

    assert bob.valid?, "We never 'saved' that bob lost his car.. so if we reload the data, the driver model should be valid again, right?"    
  end
  
end
