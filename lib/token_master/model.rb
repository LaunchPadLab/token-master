module TokenMaster

  # `TokenMaster::Model` provides the interface to the app it is used in, providing access to its public methods by invoking `TokenMaster::ClassMethods` and definiing the appropriate methods on the app model(s).
  module Model
    # Includes `TokenMaster::Model` and extends `TokenMaster::ClassMethods` to the class it's used with (automatically included via Railties)
    def self.included(base)
      base.extend(ClassMethods)
    end

    # `TokenMaster::ClassMethods` defines methods on the tokenable Class to be used in applying TokenMaster
    module ClassMethods
      # Iterates over each of the tokenables provided in the generator arguments to define the appropriate TokenMaster methods on the tokenable model
      def token_master(*tokenables)
        tokenables.each do |tokenable|
          # instance methods

          # Defines a method on the tokenable model instance to generate a tokenable action token, e.g., `user.set_confim_token!`
          define_method("set_#{tokenable}_token!") do
            TokenMaster::Core.set_token!(self, tokenable)
          end

          # Defines a method on the tokenable model instance to send tokenable action instructions, e.g., `user.send_confim_instructions!`. Accepts a block with app logic to send instructions.
          define_method("send_#{tokenable}_instructions!") do |&email|
            TokenMaster::Core.send_instructions!(self, tokenable, &email)
          end

          # Defines a method on the tokenable model instance to retrieve the status of a tokenable action, e.g., `user.confim_status`
          define_method("#{tokenable}_status") do
            TokenMaster::Core.status(self, tokenable)
          end

          # Defines a method on the tokenable model instance to force the completion of a tokenable action, e.g., `user.force_confim!`. Accepts keyword arguments for `required_params`.
          define_method("force_#{tokenable}!") do |**params|
            TokenMaster::Core.force_tokenable!(self, tokenable, **params)
          end
          # class methods

          # Defines a method on the tokenable model class to completed a tokenable action given a token, e.g., `User.confim_by_token!`. Takes the token and accepts any keyword arguments for `required_params`.
          define_singleton_method("#{tokenable}_by_token!") do |token, **params|
            TokenMaster::Core.do_by_token!(self, tokenable, token, **params)
          end
        end
      end
    end
  end
end
