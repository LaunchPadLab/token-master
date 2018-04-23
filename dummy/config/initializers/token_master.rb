TokenMaster.config do |config|
 # Set up your configurations for each tokenable using the methods at the bottom of this file
  # TokenMaster::Config::DEFAULT_VALUES =
  #     {
  #       token_lifetime: 14,
  #       required_params: [],
  #       token_length: 20
  #     }

  # Examples:
  # config.add_tokenable_options :confirm, TokenMaster::Config::DEFAULT_VALUES
  # config.add_tokenable_options :reset, token_lifetime: 1, required_params: [:password, :password_confirmation], token_length: 15
  # config.add_tokenable_options :foo, token_lifetime: 10, required_params: [:email, token_length: config.DEFAULT_VALUES[:token_length]

  #### METHODS FOR YOUR CONFIGURATION BELOW ###
  config.add_tokenable_options  :confirm, TokenMaster::Config::DEFAULT_VALUES
  config.add_tokenable_options  :reset,
                                {
                                  token_lifetime: 1,
                                  required_params: [:password, :password_confirmation],
                                  token_length: 20
                                }
  config.add_tokenable_options  :invite,
                                {
                                  token_lifetime: 10,
                                  required_params: [:password, :password_confirmation],
                                  token_length: 20
                                }
end
