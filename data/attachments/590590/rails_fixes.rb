# fix for polymorphic_path() with uncountable names
# initial patch from https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/411 for build_named_route_call()
# with a few adaptations for Rails 2.3.5
#
# Copyright (C) 2009  Marcello Nuccio <marcello.nuccio@gmail.com>
#               2010  DuckCorp
#
module ActionController
  module PolymorphicRoutes
    def build_named_route_call(records, inflection, options = {})
      unless records.is_a?(Array)
        record = extract_record(records)
        route  = ''
      else
        record = records.pop
        route = records.inject("") do |string, parent|
          if parent.is_a?(Symbol) || parent.is_a?(String)
            string << "#{parent}_"
          else
            string << RecordIdentifier.__send__("singular_class_name", parent)
            string << "_"
          end
        end
      end

      if record.is_a?(Symbol) || record.is_a?(String)
        route << "#{record}_"
      else
        singular = RecordIdentifier.__send__("singular_class_name", record)
        if inflection == :singular
          route << "#{singular}_"
        else
          plural = RecordIdentifier.__send__("plural_class_name", record)
          route << "#{plural}_#{singular == plural ? 'index_' : ''}"
        end
      end

      action_prefix(options) + route + routing_type(options).to_s
    end
  end
end
