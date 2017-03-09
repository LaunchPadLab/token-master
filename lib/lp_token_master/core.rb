
module TokenMaster  
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def token_master(*tokens)
        tokens.each do |token|
          define_method("#{token}_pending?".to_s) do
            TokenMaster.pending?(token)
          end
        end
      end
    end
  end
end