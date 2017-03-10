module TokenMaster
  class Config

    # Number of days each token is active
    attr_accessor :token_lifetimes

    # Number of characters of the token - default 20
    attr_accessor :token_length

    #Required params for certain tokenables - default password fields for invite and reset
    attr_accessor :required_params

    def initialize
      @token_length = 20
      @token_lifetimes = {
        confirm: 14,
        reset: 1,
        invite: 10
      }
      @required_params = {
        reset: [:password, :password_confirmation],
        invite: [:password, :password_confirmation]
      }
    end
  end
end
