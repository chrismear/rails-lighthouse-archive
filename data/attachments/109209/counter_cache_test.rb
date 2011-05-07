
# A bug in counter_cache when an item is updated on a polymorphic association???

# migrations:

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.integer :tasks_count
    end
  end

  def self.down
    drop_table :users
  end
end

class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.integer :tasks_count
    end
  end

  def self.down
    drop_table :projects
  end
end

class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title
      t.string :owner_type
      t.integer :owner_id
      t.integer :project_id
    end
  end

  def self.down
    drop_table :tasks
  end
end


# models:

class User < ActiveRecord::Base
  has_many :tasks, :as => :owner
  attr_readonly :tasks_count
end

class Project < ActiveRecord::Base
  has_many :tasks
end

class Task < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true, :counter_cache => true
  belongs_to :project, :counter_cache => true
end

# tests:

require 'test_helper'

class CounterCacheTest < ActiveSupport::TestCase

  def setup
    @paul = User.create :name => 'Paul'
    @sara = User.create :name => 'Sara'
    @rails = Project.create :title => 'rails'
    @sinatra = Project.create :title => 'sinatra'
  end

  test "the counter works ok when a task is assigned" do
    @paul.tasks.create :title => 'wash dishes'
    assert_equal 1, @paul.reload.tasks_count
  end
  
  test "the counter works ok when a task is deleted" do
    @paul.tasks.create :title => 'wash dishes'
    assert_equal 1, @paul.reload.tasks_count
    @paul.tasks.first.destroy
    assert_equal 0, @paul.reload.tasks_count
  end

  test "the counter works ok when a task is transferred on non polymorphic project" do
    @rails.tasks.create :title => 'testing'
    t = @rails.tasks.first
    t.update_attribute :project, @sinatra
    assert_equal 0, @rails.reload.tasks_count
    assert_equal 1, @sinatra.reload.tasks_count
  end
  
  test "the counter works ok when a task is transferred on polymorphic owner" do
    @paul.tasks.create :title => 'wash dishes'
    t = @paul.tasks.first
    t.update_attribute :owner, @sara
    assert_equal 0, @paul.reload.tasks_count # FAIL!!!
    assert_equal 1, @sara.reload.tasks_count
  end
  
end
