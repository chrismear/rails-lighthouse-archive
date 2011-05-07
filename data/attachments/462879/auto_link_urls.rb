module ActionView
  module Helpers #:nodoc:
    module TextHelper

      LINK_OPEN_TAG_RE = /<a\b.*?>/i unless const_defined?(:LINK_OPEN_TAG_RE)
      LINK_CLOSE_TAG_RE = /<\/a\b.*?>/i unless const_defined?(:LINK_CLOSE_TAG_RE)

      def auto_link_urls(text, html_options = {})
        link_attributes = html_options.stringify_keys
        text.gsub(AUTO_LINK_RE) do
          href = $&
          punctuation = ''
          left, right = $`, $'
          # detect already linked URLs and URLs in the middle of a tag
          if (left =~ /<[^>]+$/ && right =~ /^[^>]*>/) ||
             (right =~ LINK_CLOSE_TAG_RE && $` !~ LINK_OPEN_TAG_RE)
            # do not change string; URL is alreay linked
            href
          else
            # don't include trailing punctuation character as part of the URL
            if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = BRACKETS[punctuation]
              if href.scan(opening).size > href.scan(punctuation).size
                href << punctuation
                punctuation = ''
              end
            end

            link_text = block_given?? yield(href) : href
            href = 'http://' + href unless href.index('http') == 0

            content_tag(:a, h(link_text), link_attributes.merge('href' => href)) + punctuation
          end
        end
      end
    end
  end
end
