class <<ActiveRecord::Base

  #################################################
  # Public Class Methods from AR::Base
  #################################################

  def find(*args)
    options = args.extract_options!
    validate_find_options(options)
    set_readonly_option!(options)
    
    # correct the :order's
    options[:order] = format_order(options[:order]) if options && options[:order]
    if scoped_order = scope(:find, :order)
      scope(:find)[:order] = format_order(scoped_order)
    end
    
    conditions = if options && options[:conditions] && options[:conditions].is_a?(Hash)
      options[:conditions]
    end
    
    if scope(:find, :conditions) && scope(:find, :conditions).is_a?(Hash)
      conditions = scope(:find).delete(:conditions).merge(conditions || {})
    end
    
    # correct the :conditions-es
    if conditions
      options[:conditions] = format_conditions_hash(conditions)
      
      new_include = conditions2include(conditions)
      
      if options[:include].is_a?(Array)
        if new_include.is_a?(Array)
          options[:include].concat(new_include)
        else
          options[:include] << new_include
        end
        options[:include].uniq!
      elsif options[:include]
        options[:include] = [options[:include], new_include].uniq
      else
        options[:include] = new_include
      end
    end

    case args.first
      when :first then find_initial(options)
      when :all   then find_every(options)
      else             find_from_ids(args, options)
    end
  end
  
  
  # Clear the table and reset the sequence to 1
  def truncate
    connection.truncate(table_name)
  end #truncate
  
  
  # Enable either the named trigger, or all triggers for this table
  def enable_trigger(trigger = 'ALL')
    connection.enable_trigger(table_name, trigger)
  end #enable_trigger
  
  
  # Disable either the named trigger, or all triggers for this table
  def disable_trigger(trigger = 'ALL')
    connection.disable_trigger(table_name, trigger)
  end #disable_trigger
  
  #################################################
  # Private Class Methods from AR::Base
  #################################################    
  
  def format_order(sub_order, klass = self)
    case sub_order
    when Hash
      sub_order.map do |name, value|
        format_order(value, klass.reflect_on_association(name.to_sym).klass)
      end.flatten.join(',')
    when Array
      sub_order.map do |column|
        format_order(column, klass)
      end.flatten.join(',')
    else
      
      return (sub_order.to_s.split(/\s*,\s*/).collect do |str|
        # regex matches 'table_name.[column_name] asc' or 'column_name'
        # ('table_name.', 'asc', '[', and ']' are optional) $1 =
        # 'table_name.[column_name]' $2 = 'column_name' $3 = ' asc'
        str =~ /(\w+\.)?\[?(\w+)\]?(\s+asc|\s+desc)?/i
        
        if $2 && klass.column_names.include?($2)
          "#{$1 || klass.table_name+'.'}#{$2}#{$3}"
        else
          str
        end
      end).join(',')

    end #case sub_order
  end #format_order(options)

  private :format_order
  
  
  # take a conditions hash and return an :include array
  def conditions2include(conditions, original = true)
    nest = false
    new_include = *(conditions.inject([]) do |m, (k, v)|
      if v.is_a?(Hash)
        temp_v, includes_hash = conditions2include(v, false)
        nest = true
        m << (includes_hash ? {k => temp_v} : k)
      end
      m
    end)
    return original ? new_include : [new_include, nest]
  end
  private :conditions2include
  
  #####################################################
  # Overwritten Rails methods (Private Class Methods)
  #####################################################
  
  def attribute_condition(argument)
    #if (argument.is_a?(String) || argument.is_a?(Symbol)) && argument.to_s.starts_with?('!') && argument != :'!nil'
    if argument.is_a?(String) 
      if argument.to_s.starts_with?('!')
        argument.slice!(0)
        return '!= ?'
      elsif argument.to_s.starts_with?('\!')
        argument.slice!(0)
      end #if argument.to_s.starts_with?('!')
    end #if argument.is_a?(String)
    return case argument
      when nil   then "IS ?"
      when :'!nil' then "IS NOT ?"
      when Array, ActiveRecord::Associations::AssociationCollection then "IN (?)"
      when Range then "BETWEEN ? AND ?"
      else            "= ?"
    end
  end
  private :attribute_condition
  

  # NOT in Rails. My method. It is used below, which is why it's here.
  def format_conditions_hash(attrs)
    # Store values in the order they are placed in the conditions array/string
    values = []

    parse_hash = Proc.new do |hash, klass|
      hash.map do |attr, value|
        if value.is_a?(Hash)
          parse_hash.call(value, (klass || self).reflect_on_association(attr.to_sym).klass)
        else
          values << value
          "#{(klass || self).table_name}.#{connection.quote_column_name(attr)} #{attribute_condition(value)}"
        end #if value.is_a?(Hash)
      end.flatten.join(' AND ')
    end #do |hash|

    conditions = parse_hash.call(attrs)
    
    return [conditions, *values]
  end
  
  
  def sanitize_sql_hash_for_conditions(attrs)
    #attrs = expand_hash_conditions_for_aggregates(attrs)
    conditions, *values = format_conditions_hash(attrs)
    
    replace_bind_variables(conditions, expand_range_bind_variables(values))
  end
  protected :sanitize_sql_hash_for_conditions
  
  
  def quote_bound_value(value) #:nodoc:
    if value.respond_to?(:map) && !value.is_a?(String)
      if value.respond_to?(:empty?) && value.empty?
        connection.quote(nil)
      else
        value.map { |v| connection.quote(v) }.join(',')
      end
    elsif value == :'!nil'
      connection.quote(nil)
    else
      connection.quote(value)
    end
  end
  protected :quote_bound_value
  
  
  
  private
  
  # in active_record/associations.rb
  # Checks if the conditions reference a table other than the current model table
  def include_eager_conditions?(options)
    # look in both sets of conditions
    conditions = [scope(:find, :conditions), options[:conditions]].inject([]) do |all, cond|
      case cond
        when nil   then all
        when Array then all << cond.first
        else            all << cond
      end
    end
    return false unless conditions.any?
    conditions.join(' ').scan(/([\.\w]+)\.[\["]?\w+[\]"]?/).flatten.any? do |condition_table_name|
      condition_table_name != table_name
    end
  end #include_eager_conditions?
  
  
  # in active_record/associations.rb
  # Checks if the query order references a table other than the current model's table.
  def include_eager_order?(options)
    order = options[:order]
    return false unless order
    order.scan(/([\.\w]+)\.[\["]?\w+[\]"]?/).flatten.any? do |order_table_name|
      order_table_name != table_name
    end
  end #include_eager_order?

  ############################################################
  # End Overwritten Rails methods (Private Class Methods)
  ############################################################

end #class <<ActiveRecord::Base