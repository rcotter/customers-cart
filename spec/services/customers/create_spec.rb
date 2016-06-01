require 'spec_helper'

describe Api::V1::Customers::Create do

  let(:raw_params) {
    {
        id: 'ID',
        first_name: 'FIRST_NAME',
        last_name: 'LAST_NAME',
        date_of_birth: 'DATE_OF_BIRTH'
    }
  }

  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:service) { Api::V1::Customers::Create.new(params) }
  let(:customer) { double('validated customer') }
  let(:fraud_protection) { double('fraud protection') }
  let(:profile) { double('profile') }

  describe '#handle' do

    # Actual DB interactions are tested by feature tests

    before(:each) do
      allow(service).to receive(:validated_customer!).and_return customer
      allow(FraudProtectionService::Customer::Integration).to receive(:new).and_return fraud_protection
      allow(fraud_protection).to receive(:post).and_return profile
      allow(profile).to receive(:approved?).and_return 'APPROVED'
      allow(Customer).to receive(:build_with_params).and_return customer
      allow(customer).to receive(:approved=)
      allow(customer).to receive(:save!)
    end

    let(:handle) { service.handle }

    it 'validates the customer request details' do
      expect(service).to receive(:validated_customer!).and_return customer
      handle
    end

    it "retrieve customer's fraud profile" do
      expect(fraud_protection).to receive(:post).with(customer).and_return profile
      handle
    end

    it 'sets the customer approved status' do
      expect(customer).to receive(:approved=).with 'APPROVED'
      handle
    end

    it 'save the customer' do
      expect(customer).to receive(:save!)
      expect(handle).to eql customer
    end

    context 'retrieve the pre-existing' do
      before(:each) do
        allow(service).to receive(:validated_customer!).and_raise(ActiveRecord::RecordNotUnique, 'SOME MESSAGE')
      end

      it 'which exists and is returned' do
        expect(Customer).to receive(:find_by_customer_id!).with('ID').and_return customer
        expect(handle).to eql customer
      end

      it 'which does not exists and raises an error' do
        allow(Customer).to receive(:find_by_customer_id!).and_call_original
        expect { handle }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  it '#sanitized_params' do
    expected_params = raw_params.dup.stringify_keys
    raw_params.merge!(bad: 'SANITIZE_OUT')
    sanitized_params = service.send(:sanitized_params)
    expect(sanitized_params).to eql expected_params
  end

  describe '#validated_customer!' do
    before(:each) do
      allow(service).to receive(:sanitized_params).and_return params
      allow(Customer).to receive(:new).and_return customer
      allow(customer).to receive(:validate!)
    end

    let(:validated_customer!) { service.send(:validated_customer!) }

    it 'sanitizes params' do
      expect(service).to receive(:sanitized_params).and_return params
      validated_customer!
    end

    it 'creates a new customer' do
      expect(Customer).to receive(:new).with(params).and_return customer
      validated_customer!
    end

    it 'validates the customer' do
      expect(customer).to receive(:validate!)
      validated_customer!
    end

    it 'returns the customer' do
      expect(validated_customer!).to eql customer
    end
  end
end