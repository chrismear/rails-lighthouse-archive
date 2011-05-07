#!/usr/bin/ruby18

require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :computers do |table|
    table.string :model
    table.integer :vendor
  end
end

class Computer < ActiveRecord::Base
  VENDORS = ['NoName', 'Apple', 'HP']

  def vendor=(val)
    write_attribute :vendor, VENDORS.index(val) || 0
  end

  def vendor
    VENDORS[read_attribute(:vendor)] || 'unknown'
  end

  validates_uniqueness_of :model, :scope => :vendor
end

Computer.create :model => 'mbp', :vendor => 'Apple'
Computer.create :model => 'mbp', :vendor => 'Apple'
