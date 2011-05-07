# Translate duplicate key or foreign constraint insertion exceptions from generic
# StatementInvalid to specific RecordNotUnique or InvalidForeignKey
# Rollup of patch at https://rails.lighthouseapp.com/projects/8994/tickets/2419
module ActiveRecord

  # Raised when SQL statement cannot be executed by the database (for example, it's often the case for MySQL when Ruby driver used is too old).
  class StatementInvalid < ActiveRecordError
    attr_reader :original_exception
    def initialize(message, original_exception)
      super(message)
      @original_exception = original_exception
    end
  end

  # Raised when a record cannot be inserted because it would violate a uniqueness constraint.
  class RecordNotUnique < StatementInvalid
  end

  # Raised when a record cannot be inserted or updated because it references a non-existent record.
  class InvalidForeignKey < StatementInvalid
  end

  module ConnectionAdapters # :nodoc:
    class AbstractAdapter
      protected
        def log(sql, name)
          if block_given?
            result = nil
            ms = Benchmark.ms { result = yield }
            @runtime += ms
            log_info(sql, name, ms)
            result
          else
            log_info(sql, name, 0)
            nil
          end
        rescue Exception => e
          # Log message and raise exception.
          # Set last_verification to 0, so that connection gets verified
          # upon reentering the request loop
          @last_verification = 0
          message = "#{e.class.name}: #{e.message}: #{sql}"
          log_info(message, name, 0)
          raise translate_exception(e, message)
        end

        def translate_exception(e, message)
          # override in derived class
          ActiveRecord::StatementInvalid.new(message, e)
        end
    end
  end


  module ConnectionAdapters # :nodoc:
    class MysqlAdapter < AbstractAdapter
      protected
        def translate_exception(exception, message)
          case exception.errno
          when 1062
            RecordNotUnique.new(message, exception)
          when 1452
            InvalidForeignKey.new(message, exception)
          else
            super
          end
        end
    end
  end

  module ConnectionAdapters # :nodoc:
    class PostgreSQLAdapter < AbstractAdapter
      protected
        def translate_exception(exception, message)
          case exception.message
          when /duplicate key value violates unique constraint/
            RecordNotUnique.new(message, exception)
          when /violates foreign key constraint/
            InvalidForeignKey.new(message, exception)
          else
            super
          end
        end
    end
  end

  module ConnectionAdapters # :nodoc:
    class SQLiteAdapter < AbstractAdapter
      protected
        def translate_exception(exception, message)
          case exception.message
          when /column(s)? .* (is|are) not unique/
            RecordNotUnique.new(message, exception)
          else
            super
          end
        end
    end
  end

end