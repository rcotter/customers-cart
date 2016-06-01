require 'spec_helper'

describe Api::V1::Customers::Index do

  let(:params) { ActionController::Parameters.new({}) }
  let(:service) { Api::V1::Customers::Index.new(params) }
  let(:customer) { double(:customer) }

  describe '#handle' do

    # Actual DB interactions are tested by feature tests

    let(:handle) { service.handle }

    it 'returns all customers' do
      expect(Customer).to receive(:all).and_return [customer]
      expect(handle).to eql [customer]
    end
  end
end