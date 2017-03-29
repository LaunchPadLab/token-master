require 'rails/generators/active_record'

module Rails
  module Generators
    class TokenMasterGenerator < ActiveRecord::Generators::Base
      desc 'Creates a TokenMaster migration for the specified model.'

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def copy_migration
        migration_template 'migration.rb.erb', "db/migrate/#{migration_file_name}", migration_version: migration_class_name
      end

      def migration_name
        "add_token_master_to_#{name.underscore.pluralize}"
      end

      def migration_class_name
        if Rails::VERSION::MAJOR >= 5
          "ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        else
          'ActiveRecord::Migration'
        end
      end

      # check if initializer exists, if not copy over

      private
        def migration_file_name
          "#{migration_name}.rb"
        end
    end
  end
end
