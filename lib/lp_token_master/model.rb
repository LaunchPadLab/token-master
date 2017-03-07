require 'lp_token_master/error'
require 'securerandom'

module LpTokenMaster
  class Model
    class << self
      
      # helper methods for interpolation
      def do_by_token!(klass, key, token, **params)
        check_manageable! klass, key
        #check_params!(params)
        token_column = {"#{key}_token".to_sym => token}
        model = klass.find_by(token_column)
        check_token_active! model, key

        model.update!(
          params.merge({"#{key}_created_at" => Time.now})
        )
      end

      def set_token!(model, key, token_length=LpTokenMaster.config.token_length)
        check_manageable! model.class, key
        token = generate_token token_length

        model.send "#{key}_token=", token
        model.send "#{key}_created_at=", nil
        model.send "#{key}_sent_at=", nil
        model.save(validate: false)
        token
      end

      def send_instructions!(model, key)
        check_manageable! model.class, key
        check_instructions_not_sent! model, key

        yield if block_given?

        model.send "#{key}_sent_at=", Time.now
      end

      def check_manageable!(klass, key)
        raise Error, "#{klass} not #{key}able" unless manageable?(klass, key)
      end

      def manageable?(klass, key)
        return false unless klass.respond_to? :column_names
        column_names = klass.column_names

        #password doesn't care about reset at? but can include as column?
        %W(
          #{key}_token
          #{key}_at
          #{key}_sent_at
        ).all? { |attr| column_names.include? attr }
      end

      def check_token_active!(model, key)
        raise Error, "#{key} token expired" unless token_active?(model, key)
      end

      def token_active?(model, key)
        model.send("#{key}_token") &&
        model.send("#{key}_sent_at") &&
        Time.now <= (model.send("#{key}_sent_at") + (LpTokenMaster.config.send("#{key}_token_lifetime".to_sym) * 60 * 60 * 24))
      end

      def check_instructions_not_sent!(model, key)
        raise Error, "#{key} already sent" unless instructions_not_sent?(model, key)
      end

      def instructions_not_sent?(model, key)
        model.send("#{key}_sent_at".to_sym) == nil
      end

      def generate_token(length)
        rlength = (length * 3) / 4
        SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
      end
    end
  end
end
