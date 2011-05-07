##
# Asset refactoring broke expansions
# https://rails.lighthouseapp.com/projects/8994/tickets/6114
module ActionView
  module Helpers
    module AssetTagHelper
      class AssetIncludeTag
        class_eval do
          remove_method :expansions
          remove_method :expansions=
        end
      end

      class JavascriptIncludeTag
        class_attribute :expansions
        self.expansions = {}
      end

      class StylesheetIncludeTag
        class_attribute :expansions
        self.expansions = {}
      end
    end
  end
end
