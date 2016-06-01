class Api::V1::Customers::Show < Api::V1::BaseService

  # Initialize
  #
  # @param [ActionController::Parameters] params
  def initialize(params)
    @params = params
  end

  # Process the API request, delegating out to 1 or more data sources,
  # aggregating responses and assembling an API response body.
  #
  # Will raise ActiveRecord::RecordInvalid on invalid API request
  #
  # @return [Customer] for api response body
  def handle
    Customer.find_by_customer_id!(sanitized_params[:id])
  end

  private

  def sanitized_params
    @sanitized_params ||= @params.permit(:id)
  end
end