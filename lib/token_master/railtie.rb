require 'token_master/model'

module TokenMaster
  # Automatically include TokenMaster::Model in Rails/ActiveRecord apps.
  class Railtie < ::Rails::Railtie

    initializer 'token_master.active_record' do
      ActiveSupport.on_load :active_record do
        if Rails::VERSION::MAJOR >= 5
          ::ApplicationRecord.include(TokenMaster::Model)
        else
          ::ActiveRecord::Base.include(TokenMaster::Model)
        end
      end
    end
  end
end
