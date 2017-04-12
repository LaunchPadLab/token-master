module TokenMaster
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates a TokenMaster initializer in your application.'

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/token_master.rb', skip: true
      end

      def add_options
        attributes.each do |tokenable|
          inject_into_file 'config/initializers/token_master.rb', before: 'end' do <<-RUBY
  config.add_tokenable_options :#{tokenable}, TokenMaster::Config::DEFAULT_VALUES
          RUBY
          end
        end
      end
    end
  end
end
