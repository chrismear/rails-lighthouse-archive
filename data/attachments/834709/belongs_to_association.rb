module ActiveRecord
  # = Active Record Belongs To Associations
  module Associations
    class BelongsToAssociation < AssociationProxy #:nodoc:
 
      private
        def find_target
          key_column = (@reflection.options[:primary_key]) ? @reflection.options[:primary_key].to_sym : :id

          options = @reflection.options.dup
          (options.keys - [:select, :include, :readonly]).each do |key|
            options.delete key
          end
          options[:conditions] = conditions

          the_target= @reflection.klass.select(options[:select]).where(key_column => @owner[@reflection.primary_key_name]).where(options[:conditions]).includes(options[:include]).readonly(options[:readonly]).order(options[:order]).first if @owner[@reflection.primary_key_name]
          set_inverse_instance(the_target, @owner)
          the_target
        end

    end
  end
end
