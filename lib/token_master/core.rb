require 'token_master/error'
require 'securerandom'

module TokenMaster
  # `TokenMaster::Core` provides the core functionality of the TokenMaster gem. The `Core` module performs all of the logic of completing tokenable actions, and provides descriptive messages of the status or abilities of calls made.
  module Core
    class << self

      # Completes the tokenable action for a tokenable model instance using a token, setting `tokenable_completed_at` to the time at completion
      # @param [Object] klass the tokenable Class
      # @param [String, Symbol] key the tokenable action
      # @param token [String] the tokenable's token used to complete the action
      # @param params [Symbol=>String] keyword arguments required to complete the tokenable action
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @raise [TokenNotFoundError] if a tokenable instance cannot be found by the given token
      # @raise [TokenCompletedError] if the tokenable action has already been completed, i.e., the tokenable instance has a timestamp in `tokenable_completed_at`
      # @raise [TokenExpiredError] if the token is expired, i.e., the date is beyond the token's `created_at` plus `token_lifetime`
      # @raise [MissingRequiredParamsError] if the params required by a tokenable are not provided
      # @return [Object] tokenable Class instance
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

      # Completes the token action for a tokenable instance _without_ a token, setting the `tokenable_completed_at` to the time at completion.<br /> Usually implemented when you want to complete multiple tokenable actions at once, e.g., a user completes the invite action by setting up passwords, by default also completes the confirm action
      # @example Force a Tokenable Action (Confirm)
      #   user.force_confirm! =>
      #     <User id: 205, name: "John Smith", email: "jsmith@example.com", confirm_token: nil, confirm_created_at: nil, confirm_sent_at: nil, confirm_completed_at: "2017-04-25 14:17:13">
      # @param [Object] model the tokenable model instance
      # @param [String, Symbol] key the tokenable action
      # @param [Symbol=>String] params keyword arguments required to complete the tokenable action
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @raise [MissingRequiredParamsError] if the params required by a tokenable are not provided
      # @return [Object] tokenable Class instance
      def force_tokenable!(model, key, **params)
        check_manageable! model.class, key
        check_params! key, params

        model.update!(
          params.merge(completed_at_col(key) => Time.now)
        )
        model
      end

      # Generates a tokenable action token, sets the token and the time of creation on the tokenable model instance
      # @param [Object] model the tokenable model instance
      # @param [String, Symbol] key the tokenable action
      # @param [Integer] token_length the length of the generated token, method will use configuration token_length if not provided otherwise
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @return [String] token
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

      # Accepts a block to pass on a generated token through a block, such as a mailer method, and sets `tokenable_sent_at` to the time the method is called
      # @example Send Reset Instructions
      #   user.send_reset_instruction! { user.send_email } =>
      #     <User id: 205, name: "John Smith", email: "jsmith@example.com", reset_token: "3YcHkTJ7kXwV5wM", reset_created_at: 2017-04-25 14:20:54", reset_sent_at: "2017-04-25 14:22:42", reset_completed_at: nil>
      # @param [Object] model the tokenable model instance
      # @param [String, Symbol] key  the tokenable action
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @raise [TokenNotSetError] if the tokenable model instance does not have a token for the tokenable action
      # @raise [TokenSentError] if this has already been called for the instance and tokenable action, i.e., `tokenable_sent_at` is not `nil`
      # @return [Object] tokenable model instance
      def send_instructions!(model, key)
        check_manageable! model.class, key
        check_token_set! model, key
        check_instructions_sent! model, key

        yield if block_given?

        model.update(sent_at_col(key) => Time.now)
        model.save(validate: false)
      end

      # Calls set_token! and send_instructions! to generate a new token and send instructions again (accepts a block, such as a mailer method, for sending instructions).<br />Note, any previously generated token for the user will be invalid.
      # @example Resend Reset Instructions
      #   user.resend_reset_instruction! { user.send_email } =>
      #     <User id: 205, name: "John Smith", email: "jsmith@example.com", reset_token: "4ZcHkSJ8kXrV4wl", reset_created_at: 2017-04-25 16:21:54", reset_sent_at: "2017-04-25 16:22:42", reset_completed_at: nil>
      # @param [Object] model the tokenable model instance
      # @param [String, Symbol] key  the tokenable action
      # @param [Integer] token_length the length of the generated token, method will use configuration token_length if not provided otherwise
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @return [Object] tokenable model instance
      def resend_instructions!(model, key, token_length = nil)
        set_token!(model, key, token_length)
        send_instructions!(model, key)
      end

      # Provides the status of the tokenable action, whether the action has been completed, the token has been sent, the token is expired, or the token has only been created
      # @param [Object] model the tokenable model instance
      # @param [String, Symbol] key  the tokenable action
      # @raise [NotTokenableError] if the provided Class does not have the correct tokenable column
      # @return [String] status of the tokenable action:
      #  * completed
      #  * sent
      #  * expired
      #  * created
      #  * no token
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

      def check_manageable!(klass, key)
        raise Errors::NotTokenable, "#{klass} not #{key}able" unless manageable?(klass, key)
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
        raise Errors::MissingRequiredParams, 'You did not pass in the required params for this tokenable' unless required_params.all? do |k|
          params.keys.include? k
        end
      end

      def check_token_active!(model, key)
        raise Errors::TokenNotFound, "#{key} token not found" unless model
        raise Errors::TokenCompleted, "#{key} already completed" if completed?(model, key)
        raise Errors::TokenExpired, "#{key} token expired" unless token_active?(model, key)
      end

      def token_active?(model, key)
        model.send(token_col(key)) &&
          model.send(created_at_col(key)) &&
          Time.now <= (model.send(created_at_col(key)) + ((token_lifetime(key)) * 60 * 60 * 24))
      end

      def check_instructions_sent!(model, key)
        raise Errors::TokenSent, "#{key} already sent" if instructions_sent?(model, key)
      end

      def instructions_sent?(model, key)
        model.send(sent_at_col(key)).present?
      end

      def token_set?(model, key)
        model.send(token_col(key)).present?
      end

      def check_token_set!(model, key)
        raise Errors::TokenNotSet, "#{key}_token not set" unless token_set?(model, key)
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
