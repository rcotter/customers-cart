class FraudProtectionService::Integration

  attr_reader :uri
  attr_reader :request_adapter
  attr_reader :response_adapter

  # @param [String] uri to the service end point
  # @param [FraudProtectionService::_*_::RequestAdapter] request_adapter to transform requests into that accepted by the service.
  # @param [FraudProtectionService::_*_::ResponseAdapter] response_adapter to transform responses from the service.
  def initialize(uri, request_adapter, response_adapter)
    @uri = uri
    @request_adapter = request_adapter
    @response_adapter = response_adapter
  end

  # Sends the request to the service and returns a JSON friendly response
  #
  # Raises a GatewayError if the object returned by the FraudProtectionService::_*_::ResponseAdapter has a populated 'error_message' method.
  #
  # @param [Object] request that the FraudProtectionService::_*_::RequestAdapter can accept.
  # @return [Object] that the FraudProtectionService::_*_::ResponseAdapter returns
  def post(request)
    processed_request = @request_adapter.handle(request)
    gateway(request).post(processed_request) do |raw_response|
      return @response_adapter.handle(raw_response).tap { |r| error_response!(r) }
    end
  rescue JSON::ParserError => e
    {'error_message' => e.message}
  end

  private

  # Get simulated gateway or external services gateway
  #
  # @param [Object] api_request for use in the simulator
  # @return [Object] gateway with a 'post(request)' method
  def gateway(api_request)
    @gateway ||=
        simulate? ?
            SimulatedGateway.new(@response_adapter, api_request) :
            Gateway.new(@uri, 'fraud-protection-service')
  end

  # Should we simulate calls to the external service
  def simulate?
    AppConfig.fraud_protection_service.simulate?
  end

  # Raise GatewayError error on service error
  #
  # param [FraudProtectionService::Profile] response
  def error_response!(response)
    if response.try(:error_message).present?
      Rails.logger.error "Error received processing fraud protection service request: #{response.error_message}"
      raise GatewayError.new('Unable to handle request')
    end
  end
end


