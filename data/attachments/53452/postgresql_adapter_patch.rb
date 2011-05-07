module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      def add_order_by_for_association_limiting!(sql, options) #:nodoc:
        return sql if options[:order].blank?
        
        order = options[:order].is_a?(Array) ? options[:order] : options[:order].split(',')
        order = order.collect { |s| s.strip }.reject(&:blank?)
        order.map! { |s| 'DESC' if s =~ /\bdesc$/i }
        order = order.zip((0...order.size).to_a).map { |s,i| "id_list.alias_#{i} #{s}" }.join(', ')
        
        sql.replace "SELECT * FROM (#{sql}) AS id_list ORDER BY #{order}"
      end
    end
  end
end