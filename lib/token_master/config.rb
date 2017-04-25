module TokenMaster
  # `TokenMaster::Config` manages the configuration options for tokenable actions. These can be set with the initializer provided with the generator. Default values will be used if options are not specified
  class Config

    # Provides default values for a tokenable action
    # `token_lifetime` is an integer representing the number of days before the token expires
    # `required_params` is an array of symbols, e.g., `[:password, :password_confirmation]`
    # `token_length is an integer representing the number of characters in the token
    DEFAULT_VALUES = {
      token_lifetime: 14,
      required_params: [],
      token_length: 20
    }

    attr_accessor :options

    # Creates a new instance of `TokenMaster::Config`
    def initialize
      @options = {}
    end

    # Sets the key-value pairs needed to complete a tokenable action
    # Key-value pairs used to complete a tokenable action are the `token_lifetime`, `required_params` (can be blank), and the `token_length`
    # @example Set a Tokenable Option
    #   config.add_tokenable_options(:invite, { token_lifetime: 10, required_params: [:password, :password_confirmation], token_length: 12 }) #=>
    #   { invite: {
    #       token_lifetime: 10,
    #       required_params: [:password, :password_confirmation],
    #       token_length: 12
    #      }
    #    }
    # @param [Symbol] key the tokenable action
    # @param [Symbol=>[Integer, String, Array]] params the key-value pairs
    def add_tokenable_options(key, **params)
      @options[key] = params
    end

    # Retrieves the `required_params` for a tokenable_action, either as set by the application, or by the default
    # Used to update model attributes as needed for a given tokenable action
    # @param [Symbol] key the tokenable action
    # @return [Array] the `required_params` for a tokenable action
    def get_required_params(key)
      get_option(key, :required_params)
    end

    # Retrieves the `token_lifetime` for a tokenable action, either as set by the application, or by the default
    # @param [Symbol] key the tokenable action
    # @return [Integer] the `token_lifetime` for a tokenable action
    def get_token_lifetime(key)
      get_option(key, :token_lifetime)
    end

    # Retrieves the `token_length` for a tokenable action, either as set by the application, or by the default
    # @param [Symbol] key the tokenable action
    # @return [Integer] the `token_length` for a tokenable action
    def get_token_length(key)
      get_option(key, :token_length)
    end

    # Determines whether options are provided for a tokenable action
    # @param [Symbol] key the tokenable action
    # @return [Boolean] `true` => options are set; `false` => options are not set
    def options_set?(key)
      @options.key? key
    end

    private

    def get_option(key, option)
      @options.dig(key, option) || DEFAULT_VALUES[option]
    end
  end
end
