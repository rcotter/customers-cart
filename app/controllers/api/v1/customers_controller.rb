# VERY light controllers that delegate out to services
# enable cohesive behaviour and easy testing. Controllers are about API
# ingestion, routing, and rendering.

class Api::V1::CustomersController < Api::V1::BaseController

  # Creates a customer
  #
  # Uses a POST even though the customer's ID is provided instead of generated.
  # To be perfect REST it would thus be a PUT /customers/:id
  # but often that subtlety is confusing.
  #
  # @http_method POST
  # @url /customers
  def create
    @customer = Api::V1::Customers::Create.new(params).handle
    render status: (@customer.created? ? :created : :ok)
  end

  # Lists customers
  #
  # TODO Add paging query parameters. Find or make a concern!
  # 1. limit  # count to retrieve
  # 2. after  # After the entity ID
  # 3. status # 'approved', 'denied', 'all'
  #
  # @http_method GET
  # @url /customers
  def index
    @customers = Api::V1::Customers::Index.new(params).handle
    render status: :ok
  end

  # Gets a customer
  #
  # @http_method GET
  # @url /customers/id
  def show
    @customer = Api::V1::Customers::Show.new(params).handle
    render status: :ok
  end
end
