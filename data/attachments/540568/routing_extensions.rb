module ActionDispatch
  module Routing
    class Route #:nodoc:
      def required_with_default_segment_keys
        @required_with_default_segment_keys ||= begin
          required_defaults = @defaults.dup
          required_defaults.delete(:controller)
          required_defaults.delete(:action)

          non_optional_segment_keys = path.sub(/\(.+\)/, "").sub(/^\//, "").split("/")

          mark_as_optional = true
          required_dynamic_segment_keys = []
          non_optional_segment_keys.reverse_each do |key|
            is_dynamic = !!(key =~ /^:/)
            mark_as_optional  &&= is_dynamic
            if is_dynamic && !mark_as_optional
              required_dynamic_segment_keys << key[1..-1].to_sym
            end
          end

          required_defaults.keys & required_dynamic_segment_keys
        end
      end
    end

    class RouteSet #:nodoc:
      class NamedRouteCollection #:nodoc:
        def define_hash_access(route, name, kind, options)
          selector = hash_access_name(name, kind)

          @module.module_eval do
            define_method(selector) do |*args|                                  # def hash_for_users_url(*args)
              args.first ? options.merge(args.first) : options                  #   args.first ? {:only_path=>false}.merge(args.first) : {:only_path=>false}
            end                                                                 # end
            protected selector                                                  # protected :hash_for_users_url
          end
          helpers << selector
        end

        def define_url_helper(route, name, kind, options)
          selector = url_helper_name(name, kind)
          hash_access_method = hash_access_name(name, kind)

          @module.module_eval do
            define_method(selector) do |*args|
              options =  send(hash_access_method, args.extract_options!)

              if args.any?
                options[:_positional_args] = args
                options[:_positional_keys] = route.segment_keys - route.required_with_default_segment_keys
              end

              url_for(options)
            end
            protected selector
          end
          helpers << selector
        end
      end

      class Generator #:nodoc:
        def initialize(options, recall, set, extras = false)
          @script_name = options.delete(:script_name)
          @named_route = options.delete(:use_route)
          @options     = options.dup
          @recall      = recall.dup
          @set         = set
          @extras      = extras

          normalize_options!
          normalize_controller_action_id!
          use_relative_controller!
          controller.sub!(%r{^/}, '') if controller
          handle_nil_action!
          evaluate_default_options!
        end

        def evaluate_default_options!
          @options = @options.inject({}) do |h, (k, v)|
            h[k] = v.is_a?(Proc) ? v.call : v
            h
          end
        end
      end
    end
  end
end
