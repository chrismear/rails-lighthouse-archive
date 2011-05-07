# Conditions in has_many :through behave differently for joins and includes
# Here is an example using Tagging


# The important thing to note from these two models is that the 'context'
# of the Tag is kept in the Tag model and not the Tagging 
# (acts-as-taggable-on keeps it in the Tagging model)

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :delete_all
end

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
end


# The Person model sets up the required associations for the tagging
# But in this setup the relationships will work correctly for includes, not for joins

class Person < ActiveRecord::Base

  has_many :taggings, :as => :taggable, :class_name => 'Tagging', :dependent => :delete_all

  [:interests, :mannerisms].each do |context|
    has_many context, :through    => :taggings,
                      :conditions => { :tags => { :context => context.to_s } },
                      :source     => :tag
  end
end

Person.first(:joins   => [:interests, :mannerisms])
#   Person Load (0.5ms)   SELECT `people`.* FROM `people` INNER JOIN `taggings` ON (`people`.`id` = `taggings`.`taggable_id` AND `taggings`.`taggable_type` = 'Person') INNER JOIN `tags` ON (`tags`.`id` = `taggings`.`tag_id`) AND `tags`.`context` = 'interests' INNER JOIN `taggings` mannerisms_people_join ON (`people`.`id` = `mannerisms_people_join`.`taggable_id` AND `mannerisms_people_join`.`taggable_type` = 'Person') INNER JOIN `tags` mannerisms_people ON (`mannerisms_people`.`id` = `mannerisms_people_join`.`tag_id`) AND `tags`.`context` = 'mannerisms' LIMIT 1
# => nil

Performance.first(:include => [:genres, :special_tags])
#   Person Load (7.1ms)   SELECT * FROM `people` LIMIT 1
#   Tagging Load (0.5ms)   SELECT `taggings`.* FROM `taggings` WHERE (`taggings`.`taggable_id` = 1 and `taggings`.`taggable_type` = 'Person')
#   Tag Load (0.8ms)   SELECT * FROM `tags` WHERE (`tags`.`id` = 50 AND (`tags`.`context` = 'interests'))
#   Tag Load (0.8ms)   SELECT * FROM `tags` WHERE (`tags`.`id` = 51 AND (`tags`.`context` = 'mannerisms'))
# => #<Person id: 1, name: "Joe">



# And now if we make a slight change, the setup 
# is now correct for joins incorrect for includes

class Person < ActiveRecord::Base

  has_many :taggings, :as => :taggable, :class_name => 'Tagging', :dependent => :delete_all

  [:interests, :mannerisms].each do |context|
    has_many context, :through    => :taggings,
                      :conditions => { :context => context.to_s },
                      :source     => :tag
  end
end

Person.first(:joins   => [:interests, :mannerisms])
# SELECT `people`.* FROM `people` INNER JOIN `taggings` ON (`people`.`id` = `taggings`.`taggable_id` AND `taggings`.`taggable_type` = 'Person') INNER JOIN `tags` ON (`tags`.`id` = `taggings`.`tag_id`) AND tags.`context` = 'interets' INNER JOIN `taggings` mannerisms_people_join ON (`people`.`id` = `mannerisms_people_join`.`taggable_id` AND `mannerisms_people_join`.`taggable_type` = 'People') INNER JOIN `tags` mannerisms_people ON (`mannerisms_people`.`id` = `mannerisms_people_join`.`tag_id`) AND mannerisms_people.`context` = 'mannerisms' LIMIT 1
# => #<Person id: 1, name: "Joe">

Person.first(:include => [:interests, :mannerisms])
#   Person Load (0.4ms)   SELECT * FROM `people` LIMIT 1
#   Tagging Columns (2.2ms)   SHOW FIELDS FROM `taggings`
#   Tagging Load (0.4ms)   SELECT `taggings`.* FROM `taggings` WHERE (`taggings`.`taggable_id` = 1 and `taggings`.`taggable_type` = 'Person')
#   Tag Columns (1.1ms)   SHOW FIELDS FROM `tags`
#   Tag Load (0.0ms)   Mysql::Error: Unknown column 'taggings.context' in 'where clause': SELECT * FROM `tags` WHERE (`tags`.`id` = 50 AND (`taggings`.`context` = 'interests'))
# ActiveRecord::StatementInvalid: Mysql::Error: Unknown column 'taggings.context' in 'where clause': SELECT * FROM `tags` WHERE (`tags`.`id` = 50 AND (`taggings`.`context` = 'interests'))
