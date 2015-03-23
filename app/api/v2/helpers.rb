module V2
  module Helpers

    def json_wrapper(mes = '', code = 0, data)
      { message: mes, code: code, data: data }
    end

    alias_method :wrapper, :json_wrapper

    def template_path(path)
      env['api.tilt.template'] = "v2/views/#{path}"
    end
  end

  class Error < Grape::Exceptions::Base
    attr :code, :text

    def initialize(opts={})
      @code    = opts[:code]   || ''
      @text    = opts[:text]   || ''
      @status  = opts[:status] || ''

      @message = {message: @text, code: @code}
    end
  end

  class AuthorizationError < Error
    def initialize
      super code: 1001, text: 'Authorization failed', status: 403
    end
  end

  class PermissionDeniedError < Error
    def initialize
      super code: 1002, text: 'Permission denied', status: 403
    end
  end

  class TokenExpiredError < Error
    def initialize
      super code: 1003, text: 'Token expired', status: 403
    end
  end
end
