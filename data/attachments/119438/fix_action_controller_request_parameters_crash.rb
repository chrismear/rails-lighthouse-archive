if RAILS_GEM_VERSION == '2.3.2'
  module ActionController
    class Request
      # Override Rails's GET method to not crash on Rack crashes
      def GET
        @env["action_controller.request.query_parameters"] ||= begin
          normalize_parameters(super || {})
        rescue
          {}
        end
      end
      alias_method :query_parameters, :GET

      # Override Rails's POST method to not crash on Rack crashes
      def POST
        @env["action_controller.request.request_parameters"] ||= begin
          normalize_parameters(super || {})
        rescue
          {}
        end
      end
      alias_method :request_parameters, :POST
    end
  end
end
