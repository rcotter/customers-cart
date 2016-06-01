class FraudProtectionService::Customer::Integration < FraudProtectionService::Integration

  URI = "#{AppConfig.fraud_protection_service.uri}/customers_profiling"

  # Initialize
  def initialize
    request_adapter = FraudProtectionService::Customer::RequestAdapter.new
    response_adapter = FraudProtectionService::Customer::ResponseAdapter.new
    super(URI, request_adapter, response_adapter)
  end

  # POST method: post(transaction)
  #
  # The declared adapters are used to adapt request and responses regarding the given customer.
  #
  # @param [Customer] request that the FraudProtectionService::Customer::RequestAdapter can accept.
  # @return [FraudProtectionService::Customer::Profile] that the FraudProtectionService::Customer::ResponseAdapter returns
  # def post(request) ... end
end
