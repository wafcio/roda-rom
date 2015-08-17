require_relative '../config/credentials'

module HttpBasicAuthorization
  include Credentials

  # Stops processing request if the request is not over SSL.
  def require_ssl!
    request.halt(403) unless request.ssl?
  end

  # Stops processing request if request credentials don't match.
  def http_basic_authorize!(realm, username, password)
    auth = Rack::Auth::Basic::Request.new(request.env)
    unless auth.provided? && auth.basic? && auth.credentials &&
        auth.credentials == [username, password]
      response['WWW-Authenticate'] = %(Basic realm="#{realm}")
      request.halt(401)
    end
  end

  # Stops processing request if correct API request credentials were not passed.
  def authorize_api!
    http_basic_authorize!('API', api_username, api_password)
  end
end
