# API v1 base controller providing consistent error handling, authorization/authentication and logging.
class Api::V1::BaseController < ActionController::Base
  respond_to :json

  prepend_before_action :authenticate

  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception, with: :render_server_error
    rescue_from ActionController::UnknownController, with: :render_server_error
    rescue_from AbstractController::ActionNotFound, with: :render_server_error
  end

  rescue_from ActiveRecord::RecordInvalid, with: :render_error
  rescue_from GatewayError, with: :render_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found(error)
    Rails.logger.info(error)
    render nothing: true, status: 404
  end

  def render_server_error(error)
    render_error(error, 500)
  end

  def render_error(error, status=400)
    message = error.try(:message)
    Rails.logger.error("API #{status}: #{message || ''}")
    return render text: message, status: status if message
    render nothing: true, status: status
  end

  # Authenticate current caller.
  #
  # Render 401 response on failure.
  def authenticate
    authorization = request.headers['HTTP_AUTHORIZATION']#.try(:dup)
    return render_error('Authorization header required', :unauthorized) unless authorization.present?

    token_type, token = authorization.split
    return render_error('Authorization header expected as "{tokentype} {token}"', :unauthorized) unless token_type && token
    return render_error('Authorization required', :unauthorized) unless token_type == 'Basic'

    # NOTE: In a real app this would lookup a caller's credentials and compare them to what is given.
    credentials = BasicAuthCredentials.new(authorization)
    render_error(nil, :unauthorized) unless credentials.user_id == 'GOOD'
  end
end

