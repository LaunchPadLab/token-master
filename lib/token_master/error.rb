module TokenMaster

  # The base class for all errors raised by TokenMaster
  class Error < StandardError; end

  # TODO
  class MissingRequiredParams < Error; end

  # Raised when the attributes for a tokenable do not exist.
  # This could result from a migration not being run or a spelling error
  class NotTokenable < Error; end

  # TODO
  class NotConfigured < Error; end

  # TODO
  class MissingRequiredParams < Error; end

  # TODO
  class TokenNotFound < Error; end

  # TODO
  class TokenCompleted < Error; end

  # TODO
  class TokenNotCompleted < Error; end

  # TODO
  class TokenExpired < Error; end

  # TODO
  class TokenSent < Error; end

  # TODO
  class TokenNotSet < Error; end
end
