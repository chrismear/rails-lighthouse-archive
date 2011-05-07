require 'config/boot'
require 'config/environment'

class Base
  class << self
    def foo
      # ArgumentError: Anonymous modules have no name to be referenced by
      # vendor/rails/activesupport/lib/active_support/dependencies.rb:585:in `to_constant_name'
      # vendor/rails/activesupport/lib/active_support/dependencies.rb:391:in `qualified_name_for'
      # vendor/rails/activesupport/lib/active_support/dependencies.rb:104:in `const_missing'
      # rails 2.3.8
      Missing
    end
  end
end

class Sub < Base
  # Can call foo directly from base, but this is the usual use case
  foo
end
