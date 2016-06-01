# Post to an integrated service
#
# Options:
# - Subclass and override http_post to add authentication or set headers
#
class Gateway
  attr_reader :uri_path
  attr_reader :service

  # Create a new instance
  #
  # @param [String] uri_path
  # @param [String] service being called - used for logging context
  def initialize(uri_path, service)
    @uri_path = uri_path
    @service = service
  end

  # Posts a request to an external service
  #
  # @param [Hash] request body
  # @return [Hash] response body
  def post(request)
    response = http_post(request) # NOTE: This is where timing could be measured.
    raise GatewayError.new('Unable to handle request') unless response.success?
    log_call(request, response)
    yield response.body if block_given?
  rescue => e
    log_error(request, response, e.message)
  ensure
    raise "Is #{@service} accessible?" if response.nil? && !(Rails.env.production? || Rails.env.test?)
  end

  private

  # Post the request to an external service
  #
  # @param [Hash] request body
  # @return [Hash] response body
  def http_post(request)
    HTTParty.post(@uri_path, body: request)
  end

  # Log the attempted call
  #
  # @param [Hash] request body
  # @param [Hash] response body
  def log_call(request, response)
    redact_body(request)
    Rails.logger.info "#{@service} - posted with: #{request}, response was #{response.body.inspect}"
  rescue => ex
    Rails.logger.error(ex)
  end

  # Log an error
  #
  # @param [Hash] request body
  # @param [Hash] response body
  # @param [String] error_message
  def log_error(request, response, error_message)
    redact_body(request)
    Rails.logger.warn "#{@service}: #{error_message}\n\nREQUEST: #{request&.inspect}\n\nRESPONSE: #{response&.inspect}"
  rescue => ex
    Rails.logger.error(ex)
  end

  # Cleanse the request before it is logged! E.g. passwords, credit card details, etc...
  #
  # @param [Hash] request body
  def redact_body(request)
  end
end