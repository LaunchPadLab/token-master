module TokenMaster
  class Config
    DEFAULT_VALUES = {
      token_lifetime: 14,
      required_params: [],
      token_length: 20
    }

    attr_accessor :options

    def initialize
      @options = {}
    end

    def add_tokenable_options(key, **params)
      @options[key] = params
    end

    def get_required_params(key)
      get_option(key, :required_params)
    end

    def get_token_lifetime(key)
      get_option(key, :token_lifetime)
    end

    def get_token_length(key)
      get_option(key, :token_length)
    end

    def options_set?(key)
      @options.key? key
    end

    private

    def get_option(key, option)
      @options[key].fetch(option, DEFAULT_VALUES[option])
    end
  end
end
