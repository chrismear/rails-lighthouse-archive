##
# ActiveRecord::Base.joins no longer accepts nil
# https://rails.lighthouseapp.com/projects/8994/tickets/6181

module ActiveRecord
  module QueryMethods
    alias :real_joins :joins
    
    def joins(*args)
      real_joins(args.compact)
    end
  end
end
