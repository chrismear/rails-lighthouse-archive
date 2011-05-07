module ActiveRecord
  module Associations
    class AssociationCollection < AssociationProxy #:nodoc:

      protected
        def method_missing(method, *args)
          case method.to_s
          when 'find_or_create'
            return find(:first, :conditions => args.first) || create(args.first)
          when /^find_or_create_by_(.*)$/
            rest = $1
            return  send("find_by_#{rest}", *args) ||
              method_missing("create_by_#{rest}", *args)
          when /^create_by_(.*)$/
            return create($1.split('_and_').zip(args).inject({}) { |h,kv| k,v=kv ; h[k] = v ; h })
          end

          if @target.respond_to?(method) || (!@reflection.klass.respond_to?(method) && Class.respond_to?(method))
            if block_given?
              super { |*block_args| yield(*block_args) }
            else
              super unless method.to_s == "respond_to_missing?"
            end
          elsif @reflection.klass.scopes.include?(method)
            @reflection.klass.scopes[method].call(self, *args)
          else
            with_scope(construct_scope) do
              if block_given?
                @reflection.klass.send(method, *args) { |*block_args| yield(*block_args) }
              else
                @reflection.klass.send(method, *args)
              end
            end
          end
        end

    end
  end
end
