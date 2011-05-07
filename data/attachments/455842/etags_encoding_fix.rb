require 'digest/md5'

module ActionController
  class Response
    
    # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4256-response-should-be-encoded-in-charset
    def etag=(etag)
      # etag == response.body
      etag.force_encoding(charset) unless charset.blank? || etag.encoding.name.downcase == charset.downcase
      
      if etag.blank?
        headers.delete('ETag')
      else
        headers['ETag'] = %("#{Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(etag))}")
      end
    end
    
  end
end
