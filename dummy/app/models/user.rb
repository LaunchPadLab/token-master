class User < ApplicationRecord
  include TokenMaster::Core
  validates_presence_of :name, :email
  has_secure_password
  token_master :confirm, :reset, :invite

  def send_email
    'sent an email'
  end
end
