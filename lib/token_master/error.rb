module TokenMaster
  # The base class for all errors raised by TokenMaster
  class Error < StandardError; end

  # Raised when the attributes for a tokenable do not exist.
  # This could result from a migration not being run or a spelling error
  class NotTokenable < Error; end

  # Raised when the required parameters for a tokenable are not provided.
  # This typically happens with reset and invite tokenables, that might require both `password` and `password_confirmation` fields,
  # but only one is provided to the method
  class MissingRequiredParams < Error; end

  # Raised when the tokenable instance is not found
  class TokenNotFound < Error; end

  # Raised when the status of the token is reviewed, but the tokenable action has already been completed
  class TokenCompleted < Error; end

  # Raised when the token has expired based on the tokenable's `token_lifetime`
  class TokenExpired < Error; end

  # Raised when the tokenable instructions have already been sent when calling `send_tokenable_instructions!`
  class TokenSent < Error; end

  # Raised when the tokenable model instance does not have a token set for a tokenable
  class TokenNotSet < Error; end
end

