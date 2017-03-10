module TokenMaster
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates a TokenMaster initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/token_master.rb'
      end
    end
  end
end
