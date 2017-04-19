module TokenMaster
  # `TokenMaster::Config` manages the configuration options for tokenable actions. These can be set with the initializer provided with the generator, or default values will be used if options are not specified/
  class Config

    # Provides default values for a tokenable action
    DEFAULT_VALUES = {
      token_lifetime: 14,
      required_params: [],
      token_length: 20
    }

    attr_accessor :options

    # Creates a new instance of TokenMaster::Config
    def initialize
      @options = {}
    end

    # Sets the option parameters for the tokenable action
    # @param [Symbol] key the tokenable action
    # @param [Symbol=>[Intger, String, Array]] params the option parameters
    def add_tokenable_options(key, **params)
      @options[key] = params
    end

    # @param [Symbol] key the tokenable action
    # @return [Array] the `required_params` for a tokenable action
    def get_required_params(key)
      get_option(key, :required_params)
    end

    # @param [Symbol] key the tokenable action
    # @return [Integer] the `token_lifetime` for a tokenable action
    def get_token_lifetime(key)
      get_option(key, :token_lifetime)
    end

    # @param [Symbol] key the tokenable action
    # @return [Integer] the `token_length` for a tokenable action
    def get_token_length(key)
      get_option(key, :token_length)
    end

    # Determines whether option are provided for a tokenable action
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
