require 'lp_token_master/error'
require 'securerandom'

module LpTokenMaster
  class Model
    class << self

      #attr_reader for the key so not constantly passed in?
      def manageable_column_names(key)
        manageable_column_names = ["#{key}_token", "#{key}_sent_at", "#{key}_at"]
        unless key == 'confirm'
          manageable_column_names.push("password", "password_confirmation")
        end
        manageable_column_names
      end

      def do_by_token!(klass, key, token, args={})
        check_manageable! klass, key
        token_column = {"#{key}_token".to_sym => token}
        model = klass.find_by(token_column)
        check_token_active! model, key

        model.send "#{key}_at=", Time.now
        manageable_column_names = manageable_column_names(key)
        if manageable_column_names.include?("password")
          model.update(password: args[:password],
                      password_confirmation: args[:password_confirmation])
        end
        model
        # model.save
      end

      def set_token!(model, key, token_length=LpTokenMaster.config.token_length)
        check_manageable! model.class, key
        token = generate_token token_length

        model.send "#{key}_token=", token
        model.send "#{key}_at=", nil
        model.send "#{key}_at=", nil
        # model.save
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
