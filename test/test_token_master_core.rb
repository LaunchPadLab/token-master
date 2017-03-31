require 'minitest/autorun'
require 'token_master'

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
  include TokenMaster::Core
  token_master :confirm

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
    kwargs.each { |k, v| self.send("#{k}=", v) }
    self
  end
end

# TM = TokenMaster::Model
describe TokenMaster::Core do
  before do
    @tokenable_model = MockTokenMaster.new
    @klass = MockTokenMaster
    TokenMaster.config do |config|
      config.add_tokenable_options(:confirm, TokenMaster::Config::DEFAULT_VALUES)
      config.add_tokenable_options(:reset,
        token_lifetime: 2,
        required_params: [:password, :password_confirmation],
        token_length: 20)
    end
  end

  describe 'sets methods' do
    it 'instance methods' do
      assert_send([@tokenable_model, :set_confirm_token!])
      assert_send([@tokenable_model, :send_confirm_instructions!])
      assert_send([@tokenable_model, :confirm_status])
      assert_send([@tokenable_model, :force_confirm!])
    end

    it 'class methods' do
      token = 'foo'
      assert_send([@klass, :confirm_by_token!, token])
    end
  end
end
