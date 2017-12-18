require 'test_helper'

describe TokenMaster::Model do
  before do
    @bar = Class.new do |incl|
      incl.include TokenMaster::Model
      incl.token_master :confirm
    end
    @tokenable_model = @bar.new
    TokenMaster.config do |config|
      config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
      config.add_tokenable_options(
        :reset,
        token_lifetime: 2,
        required_params: [:password, :password_confirmation],
        token_length: 20
      )
    end
  end

  describe 'calls methods correctly' do
    describe 'class methods' do
      it '.do_by_token' do
        token = 'foo'
        TokenMaster::Core.stub :do_by_token!, :foo do
          assert_equal @bar.confirm_by_token!(token), :foo
        end
      end
    end

    describe 'instance methods' do
      it '#set_token!' do
        TokenMaster::Core.stub :set_token!, :foo do
          assert_equal @tokenable_model.set_confirm_token!, :foo
        end
      end

      it '#send_instructions!' do
        TokenMaster::Core.stub :send_instructions!, :foo do
          assert_equal @tokenable_model.send_confirm_instructions! {'foo'}, :foo
        end
      end

      it '#resend_instructions!' do
        TokenMaster::Core.stub :resend_instructions!, :foo do
          assert_equal @tokenable_model.resend_confirm_instructions! {'foo'}, :foo
        end
      end

      it '#status' do
        TokenMaster::Core.stub :status, :foo do
          assert_equal @tokenable_model.confirm_status, :foo
        end
      end

      it '#force_tokenable!' do
        TokenMaster::Core.stub :force_tokenable!, :foo do
          assert_equal @tokenable_model.force_confirm!, :foo
        end
      end
    end
  end
end
