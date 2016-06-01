class Api::V1::Customers::Create < Api::V1::BaseService

  # Initialize
  #
  # @param [ActionController::Parameters] params
  def initialize(params)
    @params = params
  end

  # Process the API request, delegating out to one or more data sources,
  # aggregating responses and assembling an API response body.
  #
  # Will raise ActiveRecord::RecordInvalid on invalid API request
  #
  # @return [Customer] for api response body
  def handle
    profile = fraud_protection_service.post(validated_customer!)

    validated_customer!
        .tap { |c| c.approved = profile.approved? }
        .tap { |c| c.save! }
  rescue ActiveRecord::RecordNotUnique
    Customer.find_by_customer_id!(@params[:id])
  end

  private

  def sanitized_params
    @sanitized_params ||= @params
                              .permit(
                                  :id,
                                  :first_name,
                                  :last_name,
                                  :date_of_birth)
  end

  # Create a Customer from API params and validate it. Raises ActiveRecord::RecordInvalid when invalid.
  #
  # @return [Customer] customer
  def validated_customer!
    @customer ||= Customer
                      .new(sanitized_params)
                      .tap { |r| r.validate! }
  end

  def fraud_protection_service
    FraudProtectionService::Customer::Integration.new
  end
end