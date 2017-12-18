require 'rails_helper'

RSpec.describe User, :type => :model do
  subject { build(:user) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :email }

  it { expect(subject.send_email).to eq('sent an email') }
end
