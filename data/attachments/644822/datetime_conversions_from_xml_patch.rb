module ActiveSupport
  module CoreExtensions
    module Hash
      module Conversions
        XML_PARSING = {
          "symbol"       => Proc.new  { |symbol|  symbol.to_sym },
          "date"         => Proc.new  { |date|    ::Date.parse(date) },
          "datetime"     => Proc.new  { |time|    ::Time.parse(time) rescue ::DateTime.parse(time) },
          "integer"      => Proc.new  { |integer| integer.to_i },
          "float"        => Proc.new  { |float|   float.to_f },
          "decimal"      => Proc.new  { |number|  BigDecimal(number) },
          "boolean"      => Proc.new  { |boolean| %w(1 true).include?(boolean.strip) },
          "string"       => Proc.new  { |string|  string.to_s },
          "yaml"         => Proc.new  { |yaml|    YAML::load(yaml) rescue yaml },
          "base64Binary" => Proc.new  { |bin|     ActiveSupport::Base64.decode64(bin) },
          "file"         => Proc.new do |file, entity|
            f = StringIO.new(ActiveSupport::Base64.decode64(file))
            f.extend(FileLike)
            f.original_filename = entity['name']
            f.content_type = entity['content_type']
            f
          end
        }

        XML_PARSING.update(
          "double"   => XML_PARSING["float"],
          "dateTime" => XML_PARSING["datetime"]
        )
      end
    end
  end
end