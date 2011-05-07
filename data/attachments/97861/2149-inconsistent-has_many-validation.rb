#!/usr/bin/ruby
$:.unshift(File.dirname(__FILE__) + '/../rails/activerecord/lib')
$:.unshift(File.dirname(__FILE__) + '/../rails/activesupport/lib')

require 'active_record'
require "test/unit"

# ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
ActiveRecord::Base.establish_connection(ENV['DB'] || 'test')

# Schema
ActiveRecord::Schema.define :version => 0 do

  create_table :topics, :force => true do |t|
    t.timestamps
  end

  create_table :posts, :force => true do |t|
  	t.integer :topic_id
    t.string :title
    t.text :body
  end

end

class Topic < ActiveRecord::Base
  has_many :posts
end

class TopicValidate < Topic
  has_many :posts, :validate => true, :foreign_key => 'topic_id'
end

class TopicAssociated < Topic
  validates_associated :posts, :foreign_key => 'topic_id'
end

class Post < ActiveRecord::Base
  belongs_to :topic
  validates_presence_of :title
end

class Bug2149 < Test::Unit::TestCase

  def test_case_from_new
    a = Topic.create
    a.posts << Post.new(:title => 'Spiderman')
  	assert_equal true, a.valid?
  end

  def test_fail_case_from_new
    a = Topic.create
    a.posts << Post.create
  	assert_equal false, a.valid?
  end

  def test_fail_from_pre_existing
    a = Topic.create
    a.posts << Post.create(:title => 'Spiderman')
    a.posts.first.title = nil
    assert_equal false, a.valid?
  end

  def test_that_validate_true_works
    a = TopicValidate.create
    a.posts << Post.create(:title => 'Spiderman')
    a.posts.first.title = nil
    assert_equal false, a.valid?
  end

  def test_that_validates_assocaited_works
    a = TopicAssociated.create
    a.posts << Post.create(:title => 'Spiderman')
    a.posts.first.title = nil
    assert_equal false, a.valid?
  end
 
end
