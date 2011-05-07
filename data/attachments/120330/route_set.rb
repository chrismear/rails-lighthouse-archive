module ActionController
  module Routing
    class RouteSet
      def routes_for_controller_and_action_and_keys(controller, action, keys)
        selected = {}
        routes.each do |route|
          if route.matches_controller_and_action?(controller, action)
            len = (keys - route.significant_keys).length
            selected[route] = len if not selected.values.include? len
          end
        end
        selected.keys.sort_by { |route| (keys - route.significant_keys).length }
      end
    end
  end
end

