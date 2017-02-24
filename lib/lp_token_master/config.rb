module LpTokenMaster
  class Config

    # Number of days the confirmation token is active - default 14
    attr_accessor :confirm_token_lifetime

    # Number of days the password reset token is active - default 1
    attr_accessor :reset_token_lifetime

    # Number of days the invitation token is active - default 10
    attr_accessor :invite_token_lifetime

    # Number of characters of the token - default 20
    attr_accessor :token_length

    def initialize
      @confirm_token_lifetime = 14
      @reset_token_lifetime = 1
      @invite_token_lifetime = 10
      @token_length = 20
    end
  end
end
