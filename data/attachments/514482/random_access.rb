module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Array #:nodoc:
      module RandomAccess

        alias_method :old_rand, :rand

        # Returns a random element from the array.
        def rand(value=-1)
          if (value > 0) then old_rand(value)
          else self[Kernel.rand(length)] end
        end

      end
    end
  end
end
