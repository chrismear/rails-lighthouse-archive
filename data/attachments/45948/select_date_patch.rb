def select_date(date = Date.current, options = {}, html_options = {})
  order = options[:order] || []
  order.concat([:year, :month, :day]-order)
  order.map { |option|
    send(:"select_#{option}", date, options, html_options)
  }.join(options[:date_separator] || '')
end
