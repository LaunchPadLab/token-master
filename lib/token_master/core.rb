module TokenMaster
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def token_master(*tokenables)
        tokenables.each do |tokenable|
          #instance methods
          define_method("set_#{tokenable}_token".to_s) do
            TokenMaster.set_token!(self, tokenable)
          end
          define_method("send_#{tokenable}_instruction".to_s) do
            TokenMaster.send_instructions!(self, tokenable)
          end
          define_method("#{tokenable}_pending?".to_s) do
            TokenMaster.pending?(self, tokenable)
          end
          #class methods
          define_method("self.#{tokenable}_by_token".to_s) do |token, **params|
            TokenMaster.do_by_token!(self, tokenable, token, **params)
          end
        end
      end
    end
  end
end
