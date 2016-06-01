require 'spec_helper'

describe Api::V1::Items::Update do

  let(:raw_params) { {customer_id: 'CUSTOMER_ID', id: 'ID', status: 'purchased'} }
  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:service) { Api::V1::Items::Update.new(params) }
  let(:item) { Item.new }

  describe '#handle' do

    # Actual DB interactions are tested by feature tests

    before(:each) do
      allow(service).to receive(:item).and_return item
      allow(service).to receive(:purchasing?).and_return true
      allow(item).to receive(:purchasable?).and_return true
      allow(item).to receive(:purchase!)
    end

    let(:handle) { service.handle }

    it 'checks that request is for item to be purchased' do
      expect(service).to receive(:purchasing?).and_return true
      handle
    end

    it 'raises error if items is not being purchased' do
      allow(service).to receive(:purchasing?).and_return false

      expect { handle }.to raise_error do |err|
        expect(err).is_a? ActiveRecord::RecordInvalid
        expect(err.message).to include "Status expected 'purchased'"
      end
    end

    it 'returns false if item is not purchasable' do
      expect(item).to receive(:purchasable?).and_return false
      expect(handle).to be_falsey
    end

    it 'purchases item' do
      expect(item).to receive(:purchase!)
      handle
    end

    it 'returns true when item has been purchased' do
      expect(handle).to be_truthy
    end
  end

  it '#sanitized_params' do
    expected_params = raw_params.dup.stringify_keys
    raw_params.merge!(bad: 'SANITIZE_OUT')
    sanitized_params = service.send(:sanitized_params)
    expect(sanitized_params).to eql expected_params
  end

  describe '#purchasing?' do
    let(:purchasing?) { service.send(:purchasing?) }

    it 'true' do
      params[:status] = 'purchased'
      expect(purchasing?).to be_truthy
    end

    it 'false' do
      params[:status] = 'OTHER'
      expect(purchasing?).to be_falsey
    end
  end

  describe '#item' do
    let(:items) { double('items') }
    let(:customer) { double('customer') }

    before(:each) do
      allow(Customer).to receive(:find_by_customer_id!).and_return customer
      allow(customer).to receive(:items).and_return items
      allow(items).to receive(:find_by_item_id!).and_return item
    end

    let(:get_item) { service.send(:item) }

    it 'finds the customer' do
      expect(Customer).to receive(:find_by_customer_id!).and_return customer
      get_item
    end

    it 'finds the item' do
      expect(items).to receive(:find_by_item_id!).and_return item
      get_item
    end
  end
end