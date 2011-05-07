# ActiveRecord appears to have a bug whereby record types which are in Modules
# cause errors on "include" loads
# 
# For example, the following load
#      @edition = Edition.find_by_id(edition_id, {:include => {:published_item => :user}})
# gives an error:
#      C:/Ruby/lib/ruby/gems/1.8/gems/activesupport-2.0.2/lib/active_support/dependencies.rb:266:in
#       `load_missing_constant': uninitialized constant PublishedItem (NameError)
#
# This appears to be in the following method, where "constantize" is called on
# the string "PublishedItem", which isn't a constant, although "YuduLibrary::Model::PublishedItem" is
# 
# It looks like the "reflection" object already has a constantized version of the
# classname, in reflection.klass
#
# This is a change to gems/1.8/gems/activerecord-2.0.2/lib/active_record/associations.rb
# near line 1425

# check that we're running the expected versions, otherwise this patch may be
# out of date
require 'active_record/version'
require 'test/unit'
include Test::Unit::Assertions
assert_equal("2.0.2",  ActiveRecord::VERSION::STRING)

module ActiveRecord
  module Associations
    module ClassMethods
      private
        class JoinDependency
          def remove_duplicate_results!(base, records, associations)
            case associations
              when Symbol, String
                reflection = base.reflections[associations]
                if reflection && [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
                  records.each { |record| record.send(reflection.name).target.uniq! }
                end
              when Array
                associations.each do |association|
                  remove_duplicate_results!(base, records, association)
                end
              when Hash
                associations.keys.each do |name|
                  reflection = base.reflections[name]
                  is_collection = [:has_many, :has_and_belongs_to_many].include?(reflection.macro)

                  parent_records = records.map do |record|
                    next unless record.send(reflection.name)
                    is_collection ? record.send(reflection.name).target.uniq! : record.send(reflection.name)
                  end.flatten.compact
                  # changes start here ===
                  # previous version had "reflection.class_name.constantize" 
                  # where I've put "reflection.klass"
                  #
                  # Observe that:
                  #  p reflection.klass.object_id
                  # and
                  #  p "YuduLibrary::Model::#{reflection.class_name}".constantize.object_id
                  # are the same here.
                  remove_duplicate_results!(reflection.klass, parent_records, associations[name]) unless parent_records.empty?
                  # changes end here ===
                end
            end
          end
        end
    end
  end
end
