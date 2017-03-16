require 'token_master/error'
require 'securerandom'

module TokenMaster
  class Model
    class << self
      def do_by_token!(klass, key, token, **params)
        check_manageable! klass, key
        check_params! key, params
        token_column = { token_col(key) => token }
        model = klass.find_by(token_column)
        check_token_active! model, key

        model.update!(
          params.merge({ created_at_col(key) => Time.now })
        )
      end

      def set_token!(model, key, token_length = TokenMaster.config.token_length)
        check_manageable! model.class, key
        token = generate_token token_length

        model.send token_col(key), token
        model.send created_at_col(key), nil
        model.send sent_at_col(key), nil
        model.save(validate: false)
        token
      end

      def send_instructions!(model, key)
        check_manageable! model.class, key
        check_instructions_not_sent! model, key

        yield if block_given?

        model.send sent_at_col(key), Time.now
      end

      private

        def token_col(key)
          "#{key}_token".to_sym
        end

        def created_at_col(key)
          "#{key}_created_at".to_sym
        end

        def sent_at_col(key)
          "#{key}_sent_at".to_sym
        end

        def token_lifetime(key)
          TokenMaster.config.token_lifetimes[key.to_sym]
        end

        def required_params
          TokenMaster.required_params
        end

        def check_params!(key, params)
          key = key.to_sym
          if required_params.key?(key)
            # what if user passes in extra columns / typos? It should error out
            # later on the update method. Do we want to catch that here?
            raise Error, 'You did not pass in the required params for this tokenable' unless required_params[key].all? { |value| params.keys.include? value }
          end
          return true
        end

        def check_manageable!(klass, key)
          raise Error, "#{klass} not #{key}able" unless manageable?(klass, key)
        end

        def manageable?(klass, key)
          return false unless klass.respond_to? :column_names
          column_names = klass.column_names
          %W(
            #{key}_token
            #{key}_created_at
            #{key}_sent_at
          ).all? { |attr| column_names.include? attr }
        end

        def check_token_active!(model, key)
          raise Error, "#{key} token expired" unless token_active?(model, key)
        end

        def token_active?(model, key)
          model.send(token_col(key)) &&
          model.send(sent_at_col(key)) &&
          Time.now <= (model.send(sent_at_col(key)) + ((token_lifetime(key)) * 60 * 60 * 24))
        end

        def check_instructions_not_sent!(model, key)
          raise Error, "#{key} already sent" unless instructions_not_sent?(model, key)
        end

        def instructions_not_sent?(model, key)
          model.send(sent_at_col(key)) == nil
        end

        def generate_token(length)
          rlength = (length * 3) / 4
          SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
        end
    end
  end
end
