# Fix postgres support of Infinity and friends
module ActiveRecord
  module ConnectionAdapters # :nodoc:
    class PostgreSQLAdapter
      
      quote = self.instance_method(:quote)
      # I would have done define_method(:quote) do |value, column=nil|, but such is not possible
      define_method(:quote) do |*args|
        value,column = *args
        if (value.is_a? Float)
          if value.nan?
            "'NaN'"
          elsif value.infinite?
            value > 0 ? "'Infinity'" : "'-Infifity'"
          else
            value.to_s
          end
        else
          quote.bind(self).call(value, column)
        end
      end
    end
    
    class PostgreSQLColumn
      def type_cast(value)
        if (type == :float)
          case value
            when 'Infinity' then 1.0/0.0
            when '-Infinity' then -1.0/0.0
            when 'NaN' then 0.0/0.0
            else value.to_f
          end
        else
          super
        end
      end
    end

  end
end
