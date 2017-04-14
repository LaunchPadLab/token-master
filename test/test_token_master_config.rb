require 'minitest/autorun'
require 'token_master'

describe TokenMaster::Config do
  it 'has defaults' do
    assert TokenMaster::Config::DEFAULT_VALUES[:token_lifetime]
    assert TokenMaster::Config::DEFAULT_VALUES[:required_params]
    assert TokenMaster::Config::DEFAULT_VALUES[:token_length]
  end

  it 'can be set' do
    config = TokenMaster::Config.new
    confirm_token_lifetime = 19
    config.add_tokenable_options(:confirm, token_lifetime: 19)
    assert_equal config.get_token_lifetime(:confirm), confirm_token_lifetime
  end

  describe 'returns values' do
    config = TokenMaster::Config.new

    it 'when configs set' do
      config.add_tokenable_options(:reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15)
      assert_equal config.get_token_lifetime(:reset), 1
      assert_equal config.get_required_params(:reset), [:password, :password_confirmation]
      assert_equal config.get_token_length(:reset), 15
    end

    it 'when configs not set' do
      config.add_tokenable_options(:invite, {})
      assert_equal config.get_required_params(:invite), TokenMaster::Config::DEFAULT_VALUES[:required_params]
      assert_equal config.get_token_lifetime(:invite), TokenMaster::Config::DEFAULT_VALUES[:token_lifetime]
      assert_equal config.get_token_length(:invite), TokenMaster::Config::DEFAULT_VALUES[:token_length]
    end
  end

  describe 'confirms options set' do
    before do
      @config = TokenMaster::Config.new
      @config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
    end

    it 'option not set' do
      refute @config.options_set? :invite
    end

    it 'option set' do
      assert @config.options_set? :confirm
    end
  end
end
