module LpTokenMaster
  def self.config
    @config ||= LpTokenMaster::Config.new
    if block_given?
      yield @config
    else
      @config
    end
  end
end

require 'lp_token_master/config'
require 'lp_token_master/error'
require 'lp_token_master/model'
require 'lp_token_master/version'
