require 'minitest/autorun'
require 'token_master'

def days(duration = 1)
  duration * 60 * 60 * 24
end

CONFIRM_COLS = %w(
  confirm_token
  confirm_created_at
  confirm_sent_at
  confirm_completed_at
  reset_token
  reset_created_at
  reset_sent_at
  reset_completed_at
  invite_token
  invite_created_at
  invite_sent_at
  invite_completed_at
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

  def update!(**kwargs)
    MockActiveRecord.new
  end

  def save(**kwargs)
    MockActiveRecord.new
  end
end

class MockTokenMaster < MockActiveRecord
  attr_accessor *CONFIRM_COLS, :password, :password_confirmation

  def self.column_names
    CONFIRM_COLS
  end

  def self.find_by(**kwargs)
    manageable = MockTokenMaster.new
    key = kwargs.keys[0].to_s.chomp('_token')
    manageable.send("#{key}_token=", kwargs.values[0])

    if kwargs.values[0] == 'expired'
      manageable.send("#{key}_created_at=", Time.now - 1000 * days)
    end

    if kwargs.values[0] == 'active'
      manageable.send("#{key}_created_at=", Time.now - 1 * days)
    end
    manageable
  end

  def update!(**kwargs)
    model = MockTokenMaster.new
    kwargs.each { |k, v| model.send("#{k}=", v) }
    model
  end
end

module CoreExtensions
  module Time
    def present?
      !self.nil?
    end
  end

  module String
    def present?
      !self.nil?
    end
  end

  module Nil
    def present?
      !self.nil?
    end
  end
end

Time.include CoreExtensions::Time
String.include CoreExtensions::String
NilClass.include CoreExtensions::Nil

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
end

TM = TokenMaster::Model

describe TokenMaster::Model do
  before do
    TokenMaster.config do |config|
      config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
      config.add_tokenable_options(:reset,
        token_lifetime: 2,
        required_params: [:password, :password_confirmation],
        token_length: 20)
      config.add_tokenable_options(:invite,
        token_lifetime: 10,
        required_params: [:password, :password_confirmation],
        token_length: 20)
    end
  end

  describe '#manageable?' do
    it 'anything' do
      refute TM.send(:manageable?, String, String)
    end

    it 'active record' do
      refute TM.send(:manageable?, MockActiveRecord, 'confirm')
    end

    it 'manageable' do
      assert TM.send(:manageable?, MockTokenMaster, 'confirm')
    end
  end

  describe '#check_manageable!' do
    it 'anything' do
      assert_raises TokenMaster::Error do
        TM.send(:check_manageable!, String, String)
      end
    end

    it 'active record' do
      assert_raises TokenMaster::Error do
        TM.send(:check_manageable!, MockActiveRecord, 'confirm')
      end
    end

    it 'manageable' do
      assert_nil TM.send(:check_manageable!, MockTokenMaster, 'confirm')
    end
  end

  describe '#token_set?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not set' do
      refute TM.send(:token_set?, @manageable_model, 'confirm')
    end

    it 'when set' do
      @manageable_model.confirm_token = 'foo'
      assert TM.send(:token_set?, @manageable_model, 'confirm')
    end
  end

  describe '#token_set!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not set' do
      assert_raises TokenMaster::Error do
        TM.send(:token_set!, @manageable_model, 'confirm')
      end
    end

    it 'when set' do
      @manageable_model.confirm_token = 'foo'
      assert_nil TM.send(:token_set!, @manageable_model, 'confirm')
    end
  end

  describe '#token_active?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when token does not exist' do
      refute TM.send(:token_active?, @manageable_model, 'confirm')
    end

    it 'when token sent at does not exist' do
      @manageable_model.confirm_token = 'foo'
      refute TM.send(:token_active?, @manageable_model, 'confirm')
    end

    it 'when confirm token expired' do
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_created_at = Time.now - (21 * days)
      refute TM.send(:token_active?, @manageable_model, 'confirm')
    end

    it 'when token active' do
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_created_at = Time.now - (7 * days)
      assert TM.send(:token_active?, @manageable_model, 'confirm')
    end
  end

  describe '#check_token_active!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when token not active' do
      assert_raises TokenMaster::Error do
        TM.send(:check_token_active!, @manageable_model, 'confirm')
      end
    end

    it 'when token active' do
      @manageable_model.confirm_token = 'foo'
      @manageable_model.confirm_created_at = Time.now - (7 * days)
      assert_nil TM.send(:check_token_active!, @manageable_model, 'confirm')
    end
  end

  describe '#instructions_sent?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not sent' do
      refute TM.send(:instructions_sent?, @manageable_model, 'confirm')
    end

    it 'when sent' do
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      assert TM.send(:instructions_sent?, @manageable_model, 'confirm')
    end
  end

  describe '#check_instructions_sent!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not sent' do
      assert_nil TM.send(:check_instructions_sent!, @manageable_model, 'confirm')
    end

    it 'when sent' do
      @manageable_model.confirm_sent_at = Time.now - (7 * days)
      assert_raises TokenMaster::Error do
        TM.send(:check_instructions_sent!, @manageable_model, 'confirm')
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
        assert_equal @model.confirm_token.length, TokenMaster.config.get_token_length(:confirm)
      end

      it 'sets confirm created at time to now' do
        TM.set_token! @model, 'confirm'
        assert @model.confirm_created_at, Time.now
      end

      it 'sets confirmed completed at time to nil' do
        TM.set_token! @model, 'confirm'
        assert_nil @model.confirm_completed_at
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

      describe 'when required params not present' do
        it 'raises' do
          assert_raises TokenMaster::Error do
            TM.do_by_token!(@klass, 'reset', @token, { password: @new_password })
          end
        end
      end

      describe 'when required params present' do
        it 'returns the model' do
          model = TM.do_by_token!(@klass, 'confirm', @token)
          assert_instance_of MockTokenMaster, model
        end

        it 'sets the confirm completed at time to now' do
          model = TM.do_by_token!(@klass, 'confirm', @token)
          assert_in_delta model.confirm_completed_at, Time.now, 1
        end

        describe 'password fields if reset or invite' do
          it 'updates the password field if reset' do
            model = TM.do_by_token!(@klass, 'reset', @token, {password: @new_password, password_confirmation: @new_password})
            assert_equal model.password, @new_password
          end

          it 'updates the password field if invite' do
            model = TM.do_by_token!(@klass, 'invite', @token, {password: @new_password, password_confirmation: @new_password})
            assert_equal model.password, @new_password
          end
        end
      end
    end
  end

  describe '#completed?' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not completed' do
      refute TM.send(:completed?, @manageable_model, 'confirm')
    end

    it 'when completed' do
      @manageable_model.confirm_completed_at = Time.now
      assert TM.send(:completed?, @manageable_model, 'confirm')
    end
  end

  describe '#completed!' do
    before do
      @manageable_model = MockTokenMaster.new
    end

    it 'when not completed' do
      assert_raises TokenMaster::Error do
        TM.send(:completed!, @manageable_model, 'confirm')
      end
    end

    it 'when completed' do
      @manageable_model.confirm_completed_at = Time.now
      assert_nil TM.send(:completed!, @manageable_model, 'confirm')
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

  describe 'status' do
    describe 'when not manageable' do
      before do
        @klass = MockActiveRecord
        @key = 'confirm'
        @token = 'active'
      end

      it 'raises' do
        assert_raises TokenMaster::Error do
          TM.do_by_token!(@klass, @key, @token)
        end
      end
    end

    describe 'manageable' do
      before do
        @model = MockTokenMaster.new
      end

      it 'completed' do
        @model.confirm_completed_at = Time.now
        assert_equal TM.status(@model, 'confirm'), 'completed'
      end

      it 'expired' do
        @model.confirm_token = 'foo'
        @model.confirm_created_at = Time.now - 1000 * days
        assert_equal TM.status(@model, 'confirm'), 'expired'
      end

      it 'sent' do
        @model.confirm_sent_at = Time.now
        assert_equal TM.status(@model, 'confirm'), 'sent'
      end

      it 'created' do
        @model.confirm_token = 'foo'
        @model.confirm_created_at = Time.now
        assert_equal TM.status(@model, 'confirm'), 'created'
      end

      it 'no token' do
        assert_equal TM.status(@model, 'confirm'), 'no token'
      end
    end
  end
end
