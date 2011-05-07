require 'active_support/ordered_hash'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/dependencies'

module Rails
  module Rack
    class Metal
      cattr_accessor :pass_through_on
      self.pass_through_on = 404

      def initialize(app)
        @app = app
        @pass_through_on = {}
        [*self.class.pass_through_on].each { |status| @pass_through_on[status] = true }
        
        @metals = ActiveSupport::OrderedHash.new
        self.class.metals.each { |app| @metals[app] = true }
        freeze
      end

      def call(env)
        @metals.keys.each do |app|
          result = app.call(env)
          return result unless @pass_through_on.include?(result[0].to_i)
        end
        @app.call(env)
      end
    end
  end
end

Rails::Rack::Metal.pass_through_on = 417