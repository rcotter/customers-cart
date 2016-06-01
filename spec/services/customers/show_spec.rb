require 'spec_helper'

describe Api::V1::Customers::Show do

  let(:raw_params) { {id: '1234'} }
  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:service) { Api::V1::Customers::Show.new(params) }
  let(:customer) { double(:customer) }

  describe '#handle' do

    # Actual DB interactions are tested by feature tests

    let(:handle) { service.handle }

    before(:each) do
      allow(service).to receive(:sanitized_params).and_return raw_params
      allow(Customer).to receive(:find_by_customer_id!).and_return customer
    end

    it 'sanitizes params' do
      expect(service).to receive(:sanitized_params).and_return raw_params
      handle
    end

    it 'returns customer' do
      expect(Customer).to receive(:find_by_customer_id!).with('1234').and_return customer
      expect(handle).to eql customer
    end

    it 'raises error when customer does not exist' do
      allow(Customer).to receive(:find_by_customer_id!).and_call_original
      expect { handle }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  it '#sanitized_params' do
    expected_params = raw_params.dup.stringify_keys
    raw_params.merge!(bad: 'SANITIZE_OUT')
    sanitized_params = service.send(:sanitized_params)
    expect(sanitized_params).to eql expected_params
  end
end