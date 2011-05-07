# ActionController::Request#parameters Hacks
# by: Slippy Douglas (rails@slippyd.com)
# 
# Fixes ActionController::Request::parameters (AKA params) to deeply merge GET query params and POST params.
# This replaces the normal hash merging with a "deep merge", keeping 1st-level POST params from getting overwritten by 1st-level GET params.
# 
# To use, put this file in lib, then put
#   require 'actioncontroller_request_parameters_hacks'
# in a
#   config.after_initialize do …
# block in environment.rb.

module ActionController
  class Request
    
    def parameters
      @parameters ||= request_parameters.to_hash.deep_merge(query_parameters.to_hash).update(path_parameters).with_indifferent_access
    end
    
  end
end
