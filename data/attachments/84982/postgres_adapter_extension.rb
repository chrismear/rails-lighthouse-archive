module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
          def xml(*args)
            options = args.extract_options!
             column(args[0], :xml, options)
          end
    end
  end
end