require 'spec_helper'

describe 'Customers API', type: :request do

  let(:customer_id) { SecureRandom.uuid.to_s }
  let(:freebie_item_id) { SecureRandom.uuid.to_s }

  let(:params) {
    {
        id: customer_id,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        date_of_birth: '1980-09-28'
    }
  }

  let(:expected_response) {
    params
        .dup
        .tap do |p|
      p[:name] = "#{p[:first_name]} #{p[:last_name]}"
      p.delete(:first_name)
      p.delete(:last_name)
    end
        .merge(
            {
                status: 'approved',
                cart: {
                    cart_total: '$0.0',
                    items: [
                        {
                            id: freebie_item_id,
                            name: 'Free Gift Card',
                            amount: '$50.0',
                            status: 'purchased'
                        }
                    ]
                }
            }
        )
        .deep_stringify_keys
  }

  before(:each) do
    expected_response
    allow(SecureRandom).to receive(:uuid).and_return freebie_item_id
  end

  def create_customer
    post api_v1_customers_path,
         params.to_json,
         generate_headers
  end

  describe 'creating a customer' do
    it '201 - succeeds' do
      create_customer
      expect(json_response).to eql expected_response
      expect_created
    end

    it '200 - allows re-trying when they already exist' do

      # NOTE: The customer already exists by ID. The just given details may be different.
      #       Alternatively, we could decide to return 409 or similar if any details mismatch.
      #       The difference is perfect clarity between enabling safe re-tries and accidental re-creation.

      expect(Customer.count).to eql 0
      create_customer
      expect(Customer.count).to eql 1
      create_customer
      expect(Customer.count).to eql 1

      expect(json_response).to eql expected_response
      expect_ok
    end

    [:id, :first_name, :last_name, :date_of_birth].each do |required_param|
      it "400 - disallows missing #{required_param}" do
        params.delete(required_param)
        create_customer
        expect_bad_request(required_param.to_s.humanize)
      end
    end

    it '401 - authorizes caller' do
      allow(self).to receive(:generate_headers).and_return generate_headers('BAD')
      create_customer
      expect_not_authorized
    end
  end

  describe 'retrieving a list of customers' do
    def get_customers
      get api_v1_customers_path,
          {},
          generate_headers
    end

    it '200 - there is at least one' do
      create_customer
      get_customers
      expect(json_response).to eql [{'id' => customer_id}]
      expect_ok
    end

    it '200 - there are not any' do
      get_customers
      expect(json_response).to eql []
      expect_ok
    end

    it '401 - authorizes caller' do
      allow(self).to receive(:generate_headers).and_return generate_headers('BAD')
      get_customers
      expect_not_authorized
    end
  end

  describe 'retrieving a single customer' do
    def get_customer
      get api_v1_customer_path(id: customer_id), {}, generate_headers
    end

    it '200 - succeeds' do
      create_customer
      get_customer
      expect(json_response).to eql expected_response
      expect_ok
    end

    it '401 - unauthorized caller' do
      allow(self).to receive(:generate_headers).and_return generate_headers('BAD')
      get_customer
      expect_not_authorized
    end

    it '404 - does not exist' do
      get_customer
      expect(response.body).to eql ''
      expect_not_found
    end
  end
end