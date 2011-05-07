module ActionDispatch
  module Session

    class AbstractStore

      class SessionHash < Hash
        def initialize(by, env)
          super()
          @by = by
          @env = env
          @loaded = false
          @changed = false
        end

        def changed?
          @changed
        end

        private

        def load_for_write!
          load! unless loaded?
          @changed = true
        end

      end

      def call(env)
        prepare!(env)
        response = @app.call(env)

        session_data = env[ENV_SESSION_KEY]
        options = env[ENV_SESSION_OPTIONS_KEY]

        if !session_data.is_a?(AbstractStore::SessionHash) || (session_data.loaded? && session_data.changed?) # || options[:expire_after]  # see ticket 4450
          session_data.send(:load!) if session_data.is_a?(AbstractStore::SessionHash) && !session_data.loaded?

          sid = options[:id] || generate_sid
          session_data = session_data.to_hash

          value = set_session(env, sid, session_data)
          return response unless value

          cookie = { :value => value }
          unless options[:expire_after].nil?
            cookie[:expires] = Time.now + options.delete(:expire_after)
          end

          request = ActionDispatch::Request.new(env)
          set_cookie(request, cookie.merge!(options))
        end

        response
      end

    end
  end
end
