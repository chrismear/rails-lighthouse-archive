class ActiveRecord::Associations::AssociationProxy
      protected
        def set_belongs_to_association_for(record)
          owner_id = @owner.send(@reflection.options[:primary_key] || :id)
          if @reflection.options[:as]
            record["#{@reflection.options[:as]}_id"]   = owner_id unless @owner.new_record?
            record["#{@reflection.options[:as]}_type"] = @owner.class.base_class.name.to_s
          else
            record[@reflection.primary_key_name] = owner_id unless @owner.new_record?
          end
        end
end

module ActiveRecord
  module Associations
    module ClassMethods
      private
        mattr_accessor :valid_keys_for_belongs_to_association
        @@valid_keys_for_belongs_to_association = [:class_name, :primary_key, :foreign_key, :foreign_type, 
          :remote, :select, :conditions, :include, :dependent, :counter_cache, :extend,
          :polymorphic, :readonly, :validate ]
    end
  end
end

class ActiveRecord::Associations::BelongsToAssociation
      private
        def find_target
          find_method = if @reflection.options[:primary_key]
                          "find_by_#{@reflection.options[:primary_key]}"
                        else
                          "find"
                        end
          @reflection.klass.send(find_method,
            @owner[@reflection.primary_key_name],
            :select     => @reflection.options[:select],
            :conditions => conditions,
            :include    => @reflection.options[:include],
            :readonly   => @reflection.options[:readonly]
          )
        end
end