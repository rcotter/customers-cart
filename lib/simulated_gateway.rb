# Simulated gateway that stubs out a real gateway
class SimulatedGateway

  # Initialize
  #
  # @param [FraudProtectionService::ResponseAdapter] response_adapter
  # @param [Customer] api_request that is raw for use creating simulated requests
  def initialize(response_adapter, api_request)
    @response_adapter = response_adapter
    @api_request = api_request
  end

  # Post the request and call given block with FraudProtectionService::*::ResponseAdapter.simulated_response
  #
  # @param [Hash] request that FraudProtectionService::*::RequestAdapter.handle returns
  def post(request)
    response = @response_adapter.simulated_response(request, @api_request).to_json
    yield response if block_given?
  end
end