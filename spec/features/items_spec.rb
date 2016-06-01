require 'spec_helper'

describe 'Items API', type: :request do

  let(:customer_id) { SecureRandom.uuid.to_s }
  let(:item_id) { SecureRandom.uuid.to_s }

  let(:params) {
    {
        name: 'SOME ITEM',
        amount: 123.45
    }
  }

  let(:expected_response) {
    {
        id: item_id,
        name: 'SOME ITEM',
        amount: '$123.45',
        status: 'in_cart'
    }.deep_stringify_keys
  }

  def create_customer
    post api_v1_customers_path,
         {
             id: customer_id,
             first_name: Faker::Name.first_name,
             last_name: Faker::Name.last_name,
             date_of_birth: '1980-09-28'
         }.to_json,
         generate_headers
  end

  before(:each) do
    expected_response
    allow(SecureRandom).to receive(:uuid).and_return item_id
  end

  def add_item_to_cart
    post api_v1_customer_items_path(customer_id: customer_id),
         params.to_json,
         generate_headers
  end

  describe "add an item to a customer's cart" do
    it '201 - succeeds' do
      create_customer
      add_item_to_cart
      expect(json_response).to eql expected_response
      expect_created
    end

    it '401 - authorizes caller' do
      allow(self).to receive(:generate_headers).and_return generate_headers('BAD')
      create_customer
      expect_not_authorized
    end

    [:name, :amount].each do |required_param|
      it "400 - disallows missing #{required_param}" do
        create_customer
        params.delete(required_param)
        add_item_to_cart
        expect_bad_request(required_param.to_s.humanize)
      end
    end

    it '404 - fails for a missing customer' do
      add_item_to_cart
      expect(response.body).to eql ''
      expect_not_found
    end
  end

  describe "purchasing single item already in a customer's cart" do
    before { add_item_to_cart }

    def purchase_item_in_cart
      patch api_v1_customer_item_path(customer_id: customer_id, id: item_id),
            {status: 'purchased'}.to_json,
            generate_headers
    end

    it '200 - succeeds' do
      create_customer
    end

    it '400 - cannot purchase an already bought item' do
      create_customer
      purchase_item_in_cart
      purchase_item_in_cart
      expect_not_allowed
    end

    it '401 - unauthorized caller' do
      allow(self).to receive(:generate_headers).and_return generate_headers('BAD')
      create_customer
      purchase_item_in_cart # TODO make a shared example
      expect_not_authorized
    end

    it '404 - fails for a missing customer' do
      purchase_item_in_cart
      expect(response.body).to eql ''
      expect_not_found
    end
  end
end