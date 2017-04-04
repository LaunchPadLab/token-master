module TokenMaster
  class Error < StandardError
  end

  class NotTokenable < Error
  end

  class NotConfigured < Error
  end

  class MissingRequiredParams < Error
  end

  class TokenNotFound < Error
  end

  class TokenCompleted < Error
  end

  class TokenNotCompleted < Error
  end

  class TokenExpired < Error
  end

  class TokenSent < Error
  end

  class TokenNotSet < Error
  end
end
