# VERY light controllers that delegate out to services
# enable cohesive behaviour and easy testing. Controllers are about API
# ingestion, routing, and rendering.

class Api::V1::ItemsController < Api::V1::BaseController

  # Add an item to the customer's cart
  #
  # @http_method POST
  # @url /customers/:customer_id/items
  def create
    @item = Api::V1::Items::Create.new(params).handle
    render status: 201
  end

  # Purchase an item
  #
  # @http_method PATCH
  # @url /customers/:customer_id/items/:id
  def update
    purchased = Api::V1::Items::Update.new(params).handle
    return render nothing: true, status: 200 if purchased
    render nothing: true, status: 405 # Not allowed
  end

  # TODO All item removal aka delete/destroy
end
