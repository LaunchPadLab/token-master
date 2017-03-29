module TokenMaster
  def self.config
    @config ||= TokenMaster::Config.new
    if block_given?
      yield @config
    else
      @config
    end
  end
end

require 'token_master/config'
require 'token_master/error'
require 'token_master/core'
require 'token_master/model'
require 'token_master/version'
# require 'token_master/railtie' if defined?(::Rails)
