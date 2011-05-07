module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      # The 2.3.3 implementation of this method assumes nothing follows ASC/DESC. This prevents NULLS FIRST/NULLS LAST
      # from being used in conjunction with eager loading.
      def add_order_by_for_association_limiting!(sql, options)
        return sql if options[:order].blank?
    
        order = options[:order].split(',').collect { |s| s.strip }.reject(&:blank?)
        order.map! { |s| $1.upcase if s =~ /\b((asc|desc).*)$/i }
        order = order.zip((0...order.size).to_a).map { |s,i| "id_list.alias_#{i} #{s}" }.join(', ')
    
        sql.replace "SELECT * FROM (#{sql}) AS id_list ORDER BY #{order}"
      end
    end
  end
end