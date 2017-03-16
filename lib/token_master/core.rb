module TokenMaster
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

# test - when call token_master, does it call the right methods (instance v class)
# try calling one of the defined methods, confirm it called the right things
    module ClassMethods
      def token_master(*tokenables)
        tokenables.each do |tokenable|
          # instance methods
          define_method("set_#{tokenable}_token".to_sym) do
            TokenMaster.set_token!(self, tokenable)
          end
          define_method("send_#{tokenable}_instruction".to_sym) do
            TokenMaster.send_instructions!(self, tokenable)
          end
          define_method(:status) do
            TokenMaster.status(self, tokenable)
          end
          # class methods
          define_singleton_method("#{tokenable}_by_token".to_sym) do |token, **params|
            TokenMaster.do_by_token!(self, tokenable, token, **params)
          end
        end
      end
    end
  end
end
