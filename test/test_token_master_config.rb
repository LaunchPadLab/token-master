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

  it 'returns values' do
    config = TokenMaster::Config.new
    config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
    assert_equal config.get_required_params(:confirm), TokenMaster::Config::DEFAULT_VALUES[:required_params]
    assert_equal config.get_token_lifetime(:confirm), TokenMaster::Config::DEFAULT_VALUES[:token_lifetime]
    assert_equal config.get_token_length(:confirm), TokenMaster::Config::DEFAULT_VALUES[:token_length]
  end

  describe 'confirms options' do
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
