require 'minitest/autorun'
require 'token_master'

describe TokenMaster::Core do
  before do
    @bar = Class.new do |incl|
      incl.include TokenMaster::Core
      incl.token_master :confirm
    end
    @tokenable_model = @bar.new
    TokenMaster.config do |config|
      config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
      config.add_tokenable_options(:reset,
        token_lifetime: 2,
        required_params: [:password, :password_confirmation],
        token_length: 20)
    end
  end

  describe 'calls methods correctly' do
    describe 'class methods' do
      it '.do_by_token' do
        token = 'foo'
        TokenMaster::Model.stub :do_by_token!, :foo do
          assert_equal @bar.confirm_by_token!(token), :foo
        end
      end
    end

    describe 'instance methods' do
      it '#set_token!' do
        TokenMaster::Model.stub :set_token!, :foo do
          assert_equal @tokenable_model.set_confirm_token!, :foo
        end
      end

      it '#send_instructions!' do
        TokenMaster::Model.stub :send_instructions!, :foo do
          assert_equal @tokenable_model.send_confirm_instructions!, :foo
        end
      end

      it '#status' do
        TokenMaster::Model.stub :status, :foo do
          assert_equal @tokenable_model.confirm_status, :foo
        end
      end

      it '#force_tokenable!' do
        TokenMaster::Model.stub :force_tokenable!, :foo do
          assert_equal @tokenable_model.force_confirm!, :foo
        end
      end
    end
  end
end
