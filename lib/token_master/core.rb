module TokenMaster
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def token_master(*tokenables)
        tokenables.each do |tokenable|
          # instance methods
          define_method("set_#{tokenable}_token!".to_sym) do
            TokenMaster::Model.set_token!(self, tokenable)
          end
          define_method("send_#{tokenable}_instructions!".to_sym) do
            TokenMaster::Model.send_instructions!(self, tokenable, &Proc.new)
          end
          define_method("#{tokenable}_status") do
            TokenMaster::Model.status(self, tokenable)
          end
          # class methods
          define_singleton_method("#{tokenable}_by_token!".to_sym) do |token, **params|
            TokenMaster::Model.do_by_token!(self, tokenable, token, **params)
          end
        end
      end
    end
  end
end
