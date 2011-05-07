module ActiveSupport
  class SafeBuffer < String
    alias safe_append= safe_concat
  end
end

module ActionView
  class Template
    module Handlers
      class Erubis < ::Erubis::Eruby
        def add_expr_escaped(src, code)
          if code =~ BLOCK_EXPR
            src << "@output_buffer.safe_append= " << code
          else
            src << "@output_buffer.safe_concat((" << code << ").to_s);"
          end
        end
      end
    end
  end
end