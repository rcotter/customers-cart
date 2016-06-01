class Api::V1::Items::Update < Api::V1::BaseService

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
    unless purchasing?
      item.errors.add(:status, "expected '#{Item::STATUS_PURCHASED}'")
      raise ActiveRecord::RecordInvalid.new(item)
    end

    return false unless item.purchasable?

    item.purchase!
    true
  end

  private

  def purchasing?
    sanitized_params[:status] == Item::STATUS_PURCHASED
  end

  def item
    @item ||= Customer
                  .find_by_customer_id!(sanitized_params[:customer_id])
                  .items
                  .find_by_item_id!(sanitized_params[:id])
  end

  def sanitized_params
    @sanitized_params ||= @params
                              .permit(
                                  :customer_id,
                                  :id,
                                  :status)
  end
end