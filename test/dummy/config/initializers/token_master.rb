TokenMaster.config do |config|
  # Set up your configurations for each tokenable using the methods at the bottom of this file.
  # Examples:

  # 'config.add_tokenable_options :confirm, TokenMaster::Config::DEFAULT_VALUES' results in:

  # config.confirm_options = {
  #   token_lifetime: 14,
  #   required_parms: [],
  #   token_length: 20
  # }

  # 'config.add_tokenable_options :reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15' results in:

  # config.reset_options = {
  #   token_lifetime: 1,
  #   required_parms: [:password, :password_confirmation],
  #   token_length: 20
  # }

  # 'config.add_tokenable_options :foo, token_lifetime: 10, required_params: [:email, token_length: config.DEFAULT_VALUES[:token_length]' results in:

  # config.foo_options = {
  #   token_lifetime: 10,
  #   required_parms: [:email],
  #   token_length: 20
  # }

  #### METHODS FOR YOUR CONFIGURATION BELOW ###
  config.add_tokenable_options :confirm, TokenMaster::Config::DEFAULT_VALUES
  config.add_tokenable_options :invite, token_lifetime: 10, required_params: [:password, :password_confirmation], token_length: 15
  config.add_tokenable_options :reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15
end
