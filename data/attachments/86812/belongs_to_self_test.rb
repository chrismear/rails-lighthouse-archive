require 'test/unit'

require 'rubygems'
require 'activerecord'

#set rails env CONSTANT (we are not actually loading rails in this test, but activerecord depends on this constant)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)

RAILS_GEM_VERSION = '2.3.0'
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
  create_table "people", :force => true do |t|
    t.integer  "most_recently_voted_for_person_id"
    t.string   "name"
  end
end

#models
class Person < ActiveRecord::Base
  belongs_to :most_recently_voted_for_person, :class_name => 'Person'
end

class BelongsToSelfTest < Test::Unit::TestCase
  
  def test_voted_for_himself
    he = Person.new(:name => "Dude")
    
    he.most_recently_voted_for_person = he
    assert_nothing_raised{
      he.save!      
    }
  end
  
end
