if RAILS_GEM_VERSION == '2.3.2'
  module ActionController
    module Routing
      class RouteSet
        def extract_request_environment(request)
          method = request.method
          if method == :post
            params_key = 'action_controller.request.request_parameters'
            
            if request && request.env && request.env.include?(params_key) && request.env[params_key].include?('_method')
              method = request.env[params_key]['_method'].to_sym
            end
          end
          
          { :method => method }
        end
      end
    end
  end
end