require 'spec_helper'

# VERY light controller testing since /features acceptances tests cover most of it.

describe Api::V1::CustomersController, type: :controller do

  before { authorize_controller }

  describe '#create' do
    let(:post_create) { post :create, format: :json, key: 'SOME VALUE' }
    let(:params) { {'key' => 'SOME VALUE', 'format' => 'json', 'controller' => 'api/v1/customers', 'action' => 'create'} }
    let(:service) { double('service') }
    let(:customer) { double('customer') }

    before(:each) do
      allow(Api::V1::Customers::Create).to receive(:new).and_return service
      allow(service).to receive(:handle).and_return customer
      allow(customer).to receive(:created?).and_return true
    end

    it 'creates the service' do
      expect(Api::V1::Customers::Create).to receive(:new).with(params).and_return service
      post_create
    end

    it 'service handles the request' do
      expect(service).to receive(:handle).and_return customer
      post_create
    end

    it 'assigns the customer for rendering' do
      post_create
      expect(assigns(:customer)).to eql customer
    end

    it 'returns 201 - Created' do
      post_create
      expect_created
    end

    it 'returns 200 - Ok' do
      allow(customer).to receive(:created?).and_return false
      post_create
      expect_ok
    end
  end

  describe '#index' do
    let(:get_index) { get :index, format: :json }
    let(:params) { {'format' => 'json', 'controller' => 'api/v1/customers', 'action' => 'index'} }
    let(:service) { double('service') }
    let(:customers) { double('customers') }

    before(:each) do
      allow(Api::V1::Customers::Index).to receive(:new).and_return service
      allow(service).to receive(:handle).and_return customers
    end

    it 'creates the service' do
      expect(Api::V1::Customers::Index).to receive(:new).with(params).and_return service
      get_index
    end

    it 'service handles the request' do
      expect(service).to receive(:handle).and_return customers
      get_index
    end

    it 'assigns the customers for rendering' do
      get_index
      expect(assigns(:customers)).to eql customers
    end

    it 'returns 200 - Ok' do
      get_index
      expect_ok
    end
  end

  describe '#show' do
    let(:get_show) { get :show, id: 'customer_id', format: :json }
    let(:params) { {'id' => 'customer_id', 'format' => 'json', 'controller' => 'api/v1/customers', 'action' => 'show'} }
    let(:service) { double('service') }
    let(:customer) { double('customer') }

    before(:each) do
      allow(Api::V1::Customers::Show).to receive(:new).and_return service
      allow(service).to receive(:handle).and_return customer
    end

    it 'creates the service' do
      expect(Api::V1::Customers::Show).to receive(:new).with(params).and_return service
      get_show
    end

    it 'service handles the request' do
      expect(service).to receive(:handle).and_return customer
      get_show
    end

    it 'assigns the customers for rendering' do
      get_show
      expect(assigns(:customer)).to eql customer
    end

    it 'returns 200 - Ok' do
      get_show
      expect_ok
    end
  end
end
