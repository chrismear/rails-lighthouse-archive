# This creates an in-memory SQLite database and reproduces #5181
#
# See https://rails.lighthouseapp.com/projects/8994/tickets/5181-activerecord-3-regression-certain-includes-hashes-fail-on-ar3-that-work-on-ar2
require 'rubygems'

I_WANT_TO_FAIL = false

if I_WANT_TO_FAIL
	gem 'activesupport', "= 3.0.0.beta4"
	gem 'activerecord', "= 3.0.0.beta4"
	require 'active_support'
	require 'active_support/core_ext/module/aliasing'
	require 'active_support/core_ext/benchmark'
	require 'active_record'
else
	gem 'activesupport', "~> 2.3.0"
	gem "activerecord",  "~> 2.3.0"
	require 'active_support'
	require 'active_record'
end

# Create a temporary database
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:', :verbosity => 'quiet')

# Migrate the tables
class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :name
    end
  end
end
class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :book_id
      t.integer :page_number
      t.text :content
    end
  end
end
class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
    end
    add_column :books, :author_id, :integer
  end
end
CreateBooks.migrate(:up)
CreatePages.migrate(:up)
CreateAuthors.migrate(:up)

# Setup base classes
class Author < ActiveRecord::Base
	has_many :books
end

class Book < ActiveRecord::Base
	has_many :pages
	belongs_to :author
end

class Page < ActiveRecord::Base
	belongs_to :book
end

# Try to find records
puts Author.find(:all, :include => [:books, {:books => :pages}], :conditions => 'pages.page_number = 1')