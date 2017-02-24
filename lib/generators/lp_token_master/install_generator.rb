module LpTokenMaster
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates an LpTokenMaster initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/lp_TokenMaster.rb'
      end
    end
  end
end
