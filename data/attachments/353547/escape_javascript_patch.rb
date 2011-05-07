module ActionView
  module Helpers
    module JavaScriptHelper
      # Escape carrier returns and single and double quotes for JavaScript segments.
      # First gsub argument for line breaks includes unicode line break character which
      # was causing havoc with JS and breaking invoice/estimate pages.
      
      JS_ESCAPE_MAP = {
         '\\' => '\\\\',
         '</' => '<\/',
         "\r\n" => '\n',
         "\n" => '\n',
         "\r" => '\n',
         " " => '\n', # this character is a unicode line break
         '"' => '\\"',
         "'" => "\\'" }

       # Escape carrier returns and single and double quotes for JavaScript segments.
       def escape_javascript(javascript)
         if javascript
           javascript.gsub(/( |\\|<\/|\r\n|[\n\r"'])/u) { JS_ESCAPE_MAP[$1] }
         else
           ''
         end
       end
    end
  end
end