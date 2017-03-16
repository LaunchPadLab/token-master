module TokenMaster
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates a TokenMaster initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/token_master.rb'
      end

      def self.arguments
        @arguments ||= arguments
      end

      def add_options
        arguments.each do |argument|
          inject_into_file 'config/initializer.rb', before: "end" do <<-'RUBY'
          # config.add_tokenable_options :#{argument}, #{TokenMaster::Config::DEFAULT_VALUES}
          RUBY
          end
        end
      end
    end
  end
end
