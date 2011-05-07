# Ugly monkey patch so Rails can load associations with more than 1000 items in
# Oracle. See: https://rails.lighthouseapp.com/projects/8994/tickets/1533
module ActiveRecord
  module AssociationPreloadOracleWorkaround
    # Oracle's IN() clause limit.
    ORACLE_LIMIT = 1000

    # Oracle's limit on number of arguments to a function.
    ORACLE_CHUNK = 255

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        class << self
          alias_method_chain(:in_or_equals_for_ids, :oracle_workaround)
        end
      end
    end

    module ClassMethods
      # Override in_or_equals_for_ids to split IN clauses that have more than
      # 1000 items in them.
      def in_or_equals_for_ids_with_oracle_workaround(ids)
        sql = ""

        if(ids.size > ORACLE_LIMIT)
          # If there are more than 1000, actually separate them into groups of
          # 255, since that seems to be the limit of Oracle's odcinumberlist().
          in_clauses = []
          0.step(ids.size, ORACLE_CHUNK) do |i|
            ids_chunk = ids[i, ORACLE_CHUNK]
            in_clauses << sanitize_sql_array(["(SELECT * FROM TABLE(sys.odcinumberlist(?)))", ids_chunk])
          end

          sql = "IN(#{in_clauses.join(" UNION ")})"
        else
          sql = in_or_equals_for_ids_without_oracle_workaround(ids)
        end

        sql
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::AssociationPreloadOracleWorkaround
