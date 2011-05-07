require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => 'test.sqlite3')
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

################################################################################

ActiveRecord::Schema.define(:version => 0) do
  create_table "authors", :force => true do |t|
    t.string :name
    t.belongs_to :product
  end

  create_table "categories", :force => true do |t|
    t.string :name
  end

  create_table "categorizations", :force => true do |t|
    t.belongs_to :product
    t.belongs_to :category
  end

  create_table "products", :force => true do |t|
    t.string :name
  end
end

################################################################################
class Author < ActiveRecord::Base
  belongs_to :product
  validates_uniqueness_of :name, :scope => [:product_id]
end

class Category < ActiveRecord::Base
  has_many :categorizations
end

class Product < ActiveRecord::Base
  has_many :categorizations
  has_many :authors

  accepts_nested_attributes_for :categorizations
  accepts_nested_attributes_for :authors
end

class Categorization < ActiveRecord::Base
  belongs_to :product
  belongs_to :category
  validates_uniqueness_of :product_id, :scope => [:category_id]
end

################################################################################

class AcceptsNestedAttributesForWithValidatesUniquenessOfTest < ActiveSupport::TestCase
  def setup
    @cat_cool   = Category.create!(:name => 'Cool products')
    @cat_uncool = Category.create!(:name => 'Uncool products')
  end

  test "should create two categorizations with different categories" do
    @product = Product.new(
      :name => 'Super',
      :categorizations_attributes => {
        0 => { :category_id => @cat_cool.id },
        1 => { :category_id => @cat_uncool.id },
      })

    assert @product.save
    assert_equal @product.categorizations.size, 2
  end

  test "should create two authors with different names" do
    @product = Product.new(
      :name => 'Super',
      :authors_attributes => {
        0 => { :name => 'John' },
        1 => { :name => 'Mary' },
      })

    assert @product.save
    assert_equal @product.authors.map(&:name).sort, %w(John Mary)
  end

  test "should not create two categorizations with same category" do
    @product = Product.new(
      :name => 'Super',
      :categorizations_attributes => {
        0 => { :category_id => @cat_cool.id },
        1 => { :category_id => @cat_cool.id },
      })

    assert !@product.save
  end

  test "should not create two authors with same names" do
    @product = Product.new(
      :name => 'Super',
      :authors_attributes => {
        0 => { :name => 'John' },
        1 => { :name => 'John' },
      })

    assert !@product.save
  end
end
