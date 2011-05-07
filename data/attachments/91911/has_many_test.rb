require 'cases/helper'
require 'models/author'
require 'models/post'

class ::InvalidPost < Post
  def validate 
    errors.add_to_base('always invalid')
  end
end

class HasManyTest < ActiveRecord::TestCase

  def test_has_many

    a = Author.create(:name => 'bob')
    p1 = InvalidPost.new(:title => 'p1', :body => 'p1')
    p1.save(false)
    p2 = InvalidPost.new(:title => 'p2', :body => 'p2')
    p2.save(false)
    a.posts = [p1, p2]

    assert ! (p1.author_id == a.id && p2.author_id.nil?), 'Set first belongs_to but not second'

  end
end
