require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 0) do
  create_table :publishers, :force => true do |t|
  end

  create_table :subscribers, :force => true do |t|
    t.integer "publisher_id"
  end
  
  create_table :taggings, :force => true do |t|
    t.integer  "tag_id"
    t.integer  "subscriber_id"
    t.datetime "created_at"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end
end

class Publisher < ActiveRecord::Base
  has_many :subscribers
end

class Subscriber < ActiveRecord::Base
  has_many :taggings
  has_many :tags, :through => :taggings

  named_scope :tagged_with, lambda {|tag| { :joins => :tags, :conditions => ["tags.name = ?", tag ] } }
end

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :subscriber
end

class Tag < ActiveRecord::Base
end

publisher = Publisher.create!

# This succeeds.
publisher.subscribers.tagged_with("a").all(:include => :tags)

# This generates invalid SQL.
publisher.subscribers.tagged_with("a.").all(:include => :tags)

