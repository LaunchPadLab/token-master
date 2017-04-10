module TokenMaster

  # TODO
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    # TODO
    module ClassMethods
      # TODO
      def token_master(*tokenables)
        tokenables.each do |tokenable|
          # instance methods
          # TODO
          define_method("set_#{tokenable}_token!".to_sym) do
            TokenMaster::Core.set_token!(self, tokenable)
          end
          # TODO
          define_method("send_#{tokenable}_instructions!".to_sym) do |&email|
            TokenMaster::Core.send_instructions!(self, tokenable, &email)
          end
          # TODO
          define_method("#{tokenable}_status") do
            TokenMaster::Core.status(self, tokenable)
          end
          # TODO
          define_method("force_#{tokenable}!") do |**params|
            TokenMaster::Core.force_tokenable!(self, tokenable, **params)
          end
          # class methods
          # TODO
          define_singleton_method("#{tokenable}_by_token!".to_sym) do |token, **params|
            TokenMaster::Core.do_by_token!(self, tokenable, token, **params)
          end
        end
      end
    end
  end
end
