class Api::V1::Customers::Index < Api::V1::BaseService

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
  # @return [Array of Customer] for api response body
  def handle
    Customer.all #TODO Page and order
  end
end