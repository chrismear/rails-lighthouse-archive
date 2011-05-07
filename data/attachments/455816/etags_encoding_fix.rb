require 'digest/md5'

module ActionController
  class Response
    
    def etag=(etag)
      # etag == response.body
      etag.force_encoding(charset) unless etag.encoding.name.downcase == charset.downcase
      
      if etag.blank?
        headers.delete('ETag')
      else
        headers['ETag'] = %("#{Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(etag))}")
      end
    end
    
  end
end
