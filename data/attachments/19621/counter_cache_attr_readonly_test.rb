require File.dirname(__FILE__) + '/../test_helper'

# With model classes in models/ directory
# class Topic
# end
#
# class Post
#   belongs_to :topic, :counter_cache => true  
# end

class CounterCacheAttrReadonlyTest < Test::Unit::TestCase
  def test_attr_readonly_not_set
    Post.create :topic_id => 1
    
    # Does not set attr_readonly for posts_count in Topic
    # Because Topic has not been loaded and defined? returns false
    assert_equal Set.new('posts_count'), Topic.attr_readonly 
  end
end