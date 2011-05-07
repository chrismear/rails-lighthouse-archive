module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Enables the use of time calculations within Time itself
      module Calculations
        def weekday?
          (1..5).include?(wday)
        end
      
        def weekdays_until(date)
          return 0 if date <= self
          (self...date).select{|day| day.weekday?}.size
        end
      end
    end
  end
end

module ActiveSupport
  module CoreExtensions
    module Numeric
      module Time
        # Returns a Date that is n number of weekdays in the future of a given Date
        def weekdays_from(date = ::Time.now.to_date)
          x = 0
          curr_date = date
          until x == self
            curr_date = curr_date + 1.days
            x += 1 if curr_date.weekday?
          end
        
          curr_date
        end
        alias :weekdays_from_now :weekdays_from
        
        # Returns a Date that is n number of weekdays in the past from a given Date
        def weekdays_ago(date = ::Time.now.to_date)
          x = 0
          curr_date = date
          until x == self
            curr_date = curr_date - 1.days
            x += 1 if curr_date.weekday?
          end
        
          curr_date
        end
      end
    end
  end
end