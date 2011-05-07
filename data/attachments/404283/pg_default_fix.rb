module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      private
        def column_definitions(table_name) #:nodoc:
          query <<-end_sql
            SELECT
              a.attname, format_type(a.atttypid, a.atttypmod),
                CASE WHEN d.adsrc ~ '^''(.*)''::(.*)$' THEN 
                  regexp_replace(d.adsrc,'^''(.*)''::(.*)$',E'\\\\1')
                ELSE
                  d.adsrc
                END AS adsrc,
              a.attnotnull
              FROM pg_attribute a LEFT JOIN pg_attrdef d
                ON a.attrelid = d.adrelid AND a.attnum = d.adnum
             WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
                AND a.attnum > 0 AND NOT a.attisdropped
              ORDER BY a.attnum;
          end_sql
        end
    end
  end
end