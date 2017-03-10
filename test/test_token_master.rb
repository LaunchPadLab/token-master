require 'minitest/autorun'
require 'token_master'

def days(duration=1)
  duration * 60 * 60 * 24
end

CONFIRM_COLS = %w(
  confirm_token
  confirm_created_at
  confirm_sent_at
  reset_token
  reset_created_at
  reset_sent_at
  invite_token
  invite_created_at
  invite_sent_at
)

class MockActiveRecord
  def self.column_names
    []
  end

  def self.find_by(**kwargs)
    MockActiveRecord.new
  end

  def update_columns(**kwargs)
    kwargs.each { |k, v| send("#{k}=", v) }
  end

  def update(**kwargs)
    kwargs.each { |k, v| send("#{k}=", v) }
  end
end

class MockTokenMaster < MockActiveRecord
  attr_accessor *CONFIRM_COLS, :email, :password, :password_confirmation

  def self.column_names
    CONFIRM_COLS
  end

  def self.find_by(**kwargs)
    manageable = MockTokenMaster.new
    key = kwargs.keys[0].to_s.chomp('_token')
    manageable.send("#{key}_token=", kwargs.values[0])

    if kwargs.values[0] == 'expired'
      manageable.send("#{key}_sent_at=", Time.now - 1000 * days)
    end

    if kwargs.values[0] == 'active'
      manageable.send("#{key}_sent_at=", Time.now - 1 * days)
    end

    # if kwargs[:token] == 'confirmed'
    #   manageable.send("#{key}_created_at=", Time.now - 1 * days)
    # end

    manageable
  end
end

describe TokenMaster::Config do
  it 'has defaults' do
    assert TokenMaster.config.confirm_token_lifetime
    assert TokenMaster.config.reset_token_lifetime
    assert TokenMaster.config.invite_token_lifetime
    assert TokenMaster.config.token_length
  end

  it 'can be set' do
    default_confirm_token_lifetime = TokenMaster.config.confirm_token_lifetime
    new_confirm_token_lifetime = default_confirm_token_lifetime + 5
    TokenMaster.config do |config|
      config.confirm_token_lifetime = new_confirm_token_lifetime
    end
    assert_equal TokenMaster.config.confirm_token_lifetime, new_confirm_token_lifetime
  end
end

TM = TokenMaster::Model

describe TokenMaster::Model do

  before do
    TokenMaster.config do |config|
      config.confirm_token_lifetime = 14
      config.reset_token_lifetime = 2
      config.invite_token_lifetime = 10
      config.token_length = 20
    end
  end

  describe '#manageable?' do

    it 'anything' do
      refute TM.manageable? String, String
    end

    it 'active record' do
      refute TM.manageable? MockActiveRecord, 'confirm'
    end

    it 'manageable' do
      assert TM.manageable? MockTokenMaster, 'confirm'
    end
  end

  describe '#check_manageable!' do

    it 'anything' do
      assert_raises TokenMaster::Error do
        TM.check_manageable! String, String
      end
    end

    it 'active record' do
      assert_raises TokenMaster::Error do
        TM.check_manageable! MockActiveRecord, 'confirm'
      end
    end

    it 'manageable' do
      assert_nil TM.check_manageable!(MockTokenMaster,'confirm')
    end
  end

  describe '#token_active?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when token does not exist' do
      refute TM.token_active?(@manageable_model, 'confirm')
    end

    it 'when token sent at does not exist' do
      @manageable_model.confirm_token = 'foo'
      refute TM.token_active?(@manageable_model, 'confirm')
    end

    it 'when confirm token expired' do
      TokenMaster.config { |config| config.confirm_token_lifetime = 14 }
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_sent_at = Time.now - (21 * days)
      refute TM.token_active?(@manageable_model, 'confirm')
    end

    it 'when token active' do
      TokenMaster.config { |config| config.confirm_token_lifetime = 14 }
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      assert TM.token_active?(@manageable_model, 'confirm')
    end
  end

  describe '#check_token_active!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when token not active' do
      assert_raises TokenMaster::Error do
        TM.check_token_active!(@manageable_model, 'confirm')
      end
    end

    it 'when token active' do
      TokenMaster.config { |config| config.confirm_token_lifetime = 14 }
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      assert_nil TM.check_token_active!(@manageable_model, 'confirm')
    end
  end

  describe '#instructions_not_sent?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not sent' do
      assert TM.instructions_not_sent?(@manageable_model, 'confirm')
    end

    it 'when sent' do
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      refute TM.instructions_not_sent?(@manageable_model, 'confirm')
    end
  end

  describe '#check_instructions_not_sent!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not sent' do
      assert_nil TM.check_instructions_not_sent!(@manageable_model, 'confirm')
    end

    it 'when sent' do
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      assert_raises TokenMaster::Error do
        TM.check_instructions_not_sent!(@manageable_model, 'confirm')
      end
    end
  end

  describe '#set_token!' do

    describe 'when not manageable' do
      before do
        @model = MockActiveRecord.new
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.set_token!(@model, 'confirm')
        end
      end
    end

    describe 'when manageable' do
      before do
        @model = MockTokenMaster.new
      end

      it 'sets the token to the configured length' do
        TM.set_token! @model, 'confirm'
        assert_equal @model.confirm_token.length, TokenMaster.config.token_length
      end

      it 'sets confirmed at time to nil' do
        TM.set_token! @model, 'confirm'
        assert_nil @model.confirm_at
      end

      it 'sets confirm sent at time to nil' do
        TM.set_token! @model, 'confirm'
        assert_nil @model.confirm_sent_at
      end

      it 'returns the token' do
        token = TM.set_token! @model, 'confirm'
        assert_equal token, @model.confirm_token
      end

      describe 'when token length is provided' do
        it 'sets the token to the provided length' do
          TM.set_token! @model, 'confirm', 40
          assert_equal @model.confirm_token.length, 40
        end
      end
    end
  end

  describe '#do_by_token!' do

    describe 'when not manageable' do
      before do
        @klass = MockActiveRecord
        @key = 'confirm'
        @token = 'foo'
        @new_password = "password"
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.do_by_token!(@klass, @key, @token)
        end
      end
    end

    describe 'when expired' do
      before do
        @klass = MockTokenMaster
        @token = 'expired'
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.do_by_token!(@klass, 'confirm', @token)
        end
      end
    end

    describe 'when active' do
      before do
        @klass = MockTokenMaster
        @token = 'active'
        @new_password = 'new_password'
      end

      it 'returns the model' do
        model = TM.do_by_token!(@klass, 'confirm', @token)
        assert_instance_of MockTokenMaster, model
      end

      it 'sets the confirmed at time to now' do
        model = TM.do_by_token!(@klass, 'confirm', @token)
        assert_in_delta model.confirm_at, Time.now, 1
      end

      describe 'password fields if reset or invite' do
        it 'updates the password field if reset' do
          model = TM.do_by_token!(@klass, 'reset', @token, {password: @new_password})
          assert_equal model.password, @new_password
        end

        it 'updates the password field if invite' do
          model = TM.do_by_token!(@klass, 'invite', @token, {password: @new_password})
          assert_equal model.password, @new_password
        end
      end
    end
  end

  describe '#send_instructions!' do
    describe 'when not manageable' do
      before do
        @model = MockActiveRecord.new
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.send_instructions!(@model, 'confirm')
        end
      end
    end

    describe 'when instructions sent' do
      before do
        @model = MockTokenMaster.new
        @model.confirm_token = 'foo'
        @model.confirm_sent_at = Time.now
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.send_instructions!(@model, 'confirm')
        end
      end
    end

    describe 'when instructions not sent' do
      before do
        @model = MockTokenMaster.new
        @model.confirm_token = 'foo'
      end

      it 'sets confirm sent at' do
        TM.send_instructions!(@model, 'confirm')
        assert_in_delta @model.confirm_sent_at, Time.now, 1
      end

      it 'calls the block if given' do
        @mock_block = Minitest::Mock.new
        @mock_block.expect(:foo, 'bar')
        TM.send_instructions!(@model, 'confirm') do
          @mock_block.foo
        end
        @mock_block.verify
      end
    end
  end
end
