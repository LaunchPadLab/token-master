require 'rails/generators/named_base'
require 'rails/generators/migration'

module TokenMaster
  module Generators
    class MigrationGenerator < Rails::Generators::NamedBase
      namespace 'token_master'
      source_route File.expand_path('../templates', __FILE__)

      desc 'Generates a migration file for the given model (NAME) with the specified tokenable columns'
    end
  end
end
