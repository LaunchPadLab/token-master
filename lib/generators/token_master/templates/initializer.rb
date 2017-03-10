TokenMaster.config do |config|

  # The number of days the token for each tokenable is active
  # default:
  # config.token_lifetimes = {
  #   confirm: 14,
  #   reset: 1,
  #   invite: 10
  # }

  # The number of characters in a token
  # default: 20
  #
  # config.token_length = 30

  # Required parameters for tokenable actions
  # default:

  # config.required_params = {
  #   reset: [:password, :password_confirmation],
  #   invite: [:password, :password_confirmation]
  # }
end
