require 'token_master/error'
require 'securerandom'

module TokenMaster
  # TODO
  module Core
    class << self
      # TODO
      def do_by_token!(klass, key, token, **params)
        check_manageable! klass, key
        token_column = { token_col(key) => token }
        model = klass.find_by(token_column)
        check_token_active! model, key
        check_params! key, params

        model.update!(
          params.merge(completed_at_col(key) => Time.now)
        )
        model
      end

      # TODO
      def force_tokenable!(model, key, **params)
        check_manageable! model.class, key
        check_params! key, params

        model.update!(
          params.merge(completed_at_col(key) => Time.now)
        )
        model
      end

      # TODO
      def set_token!(model, key, token_length = nil)
        check_manageable! model.class, key
        token_length ||= TokenMaster.config.get_token_length(key.to_sym)
        token = generate_token token_length

        model.update({
          token_col(key) => token,
          created_at_col(key) => Time.now,
          sent_at_col(key) => nil,
          completed_at_col(key) => nil
        })
        model.save(validate: false)
        token
      end

      # TODO
      def send_instructions!(model, key)
        check_manageable! model.class, key
        check_token_set! model, key
        check_instructions_sent! model, key

        yield if block_given?

        model.update(sent_at_col(key) => Time.now)
        model.save(validate: false)
      end

      # TODO
      def status(model, key)
        check_manageable! model.class, key
        return 'completed' if completed?(model, key)
        return 'sent' if instructions_sent?(model, key)
        if token_set?(model, key)
          return 'expired' unless token_active?(model, key)
          return 'created'
        end
        'no token'
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

        def completed_at_col(key)
          "#{key}_completed_at".to_sym
        end

        def token_lifetime(key)
          TokenMaster.config.get_token_lifetime(key.to_sym)
        end

        def required_params(key)
          TokenMaster.config.get_required_params(key.to_sym)
        end

        def check_manageable!(klass, key)
          raise NotTokenable, "#{klass} not #{key}able" unless manageable?(klass, key)
        end

        def manageable?(klass, key)
          return false unless klass.respond_to? :column_names
          column_names = klass.column_names
          %W(
            #{key}_token
            #{key}_created_at
            #{key}_completed_at
            #{key}_sent_at
          ).all? { |attr| column_names.include? attr }
        end

        def check_params!(key, params)
          required_params = TokenMaster.config.get_required_params(key.to_sym)
          raise MissingRequiredParams, 'You did not pass in the required params for this tokenable' unless required_params.all? do |k|
            params.keys.include? k
          end
        end

        def check_token_active!(model, key)
          raise TokenNotFound, "#{key} token not found" unless model
          raise TokenCompleted, "#{key} already completed" if completed?(model, key)
          raise TokenExpired, "#{key} token expired" unless token_active?(model, key)
        end

        def token_active?(model, key)
          model.send(token_col(key)) &&
          model.send(created_at_col(key)) &&
          Time.now <= (model.send(created_at_col(key)) + ((token_lifetime(key)) * 60 * 60 * 24))
        end

        def check_instructions_sent!(model, key)
          raise TokenSent, "#{key} already sent" if instructions_sent?(model, key)
        end

        def instructions_sent?(model, key)
          model.send(sent_at_col(key)).present?
        end

        def token_set?(model, key)
          model.send(token_col(key)).present?
        end

        def check_token_set!(model, key)
          raise TokenNotSet, "#{key}_token not set" unless token_set?(model, key)
        end

        def completed?(model, key)
          model.send(completed_at_col(key)).present?
        end

        def generate_token(length)
          rlength = (length * 3) / 4
          SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
        end
    end
  end
end
