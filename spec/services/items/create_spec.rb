require 'spec_helper'

describe Api::V1::Customers::Create do

  let(:raw_params) {
    {
        customer_id: 'CUSTOMER_ID',
        name: 'NAME',
        amount: 123.45,
        status: 'APPROVED'
    }
  }

  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:service) { Api::V1::Items::Create.new(params) }
  let(:customer) { double('customer') }
  let(:items) { [] }
  let(:item) { double('item') }

  describe '#handle' do

    # Actual DB interactions are tested by feature tests

    before(:each) do
      allow(service).to receive(:sanitized_params).and_return params
      allow(Customer).to receive(:find_by_customer_id!).and_return customer
      allow(customer).to receive(:items).and_return items
      allow(items).to receive(:<<)
      allow(service).to receive(:validated_item!).and_return item
    end

    let(:handle) { service.handle }

    it 'sanitizes params' do
      expect(service).to receive(:sanitized_params).and_return params
      handle
    end

    it 'finds the customer' do
      expect(Customer).to receive(:find_by_customer_id!).with('CUSTOMER_ID').and_return customer
      handle
    end

    it 'raises error when customer does not exist' do
      allow(Customer).to receive(:find_by_customer_id!).and_call_original
      expect { handle }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'validates the item request details' do
      expect(service).to receive(:validated_item!).and_return item
      handle
    end

    it 'adds item to customer item association' do
      expect(items).to receive(:<<).with item
      handle
    end

    it 'returns item' do
      expect(handle).to eql item
    end
  end

  it '#sanitized_params' do
    expected_params = raw_params.dup.stringify_keys
    raw_params.merge!(bad: 'SANITIZE_OUT')
    sanitized_params = service.send(:sanitized_params)
    expect(sanitized_params).to eql expected_params
  end

  describe '#validated_item!' do
    before(:each) do
      allow(service).to receive(:sanitized_params).and_return params
      allow(Item).to receive(:new).and_return item
      allow(item).to receive(:validate!)
    end

    let(:validated_item!) { service.send(:validated_item!) }

    it 'sanitizes params' do
      expect(service).to receive(:sanitized_params).and_return params
      validated_item!
    end

    it 'creates a new item' do
      expect(Item).to receive(:new).with(params).and_return item
      validated_item!
    end

    it 'validates the item' do
      expect(item).to receive(:validate!)
      validated_item!
    end

    it 'returns the item' do
      expect(validated_item!).to eql item
    end
  end
end