class Api::V1::Items::Create < Api::V1::BaseService

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
  def handle
    customer = Customer.find_by_customer_id!(sanitized_params[:customer_id])
    customer.items << validated_item!
    validated_item!
  end

  private

  def validated_item!
    @cart_item ||= Item
                       .new(sanitized_params)
                       .tap { |i| i.validate! }
  end

  def sanitized_params
    @sanitized_params ||= @params
                              .permit(
                                  :customer_id,
                                  :name,
                                  :amount,
                                  :status)
  end
end