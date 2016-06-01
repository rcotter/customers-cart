# == Schema Information
#
# Table name: items
#
#  amount_cents :integer          not null
#  created_at   :datetime         not null
#  customer_id  :string           not null
#  id           :integer          not null, primary key
#  item_id      :string           not null
#  name         :string           not null
#  purchased_at :integer
#  status       :string           not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

# VERY light controller testing since /features acceptances tests cover most of it.

describe Api::V1::ItemsController, type: :controller do

  before { authorize_controller }

  describe '#create' do
    let(:post_create) { post :create, format: :json, customer_id: 'customer_id', key: 'SOME VALUE' }
    let(:params) { {'customer_id' => 'customer_id', 'key' => 'SOME VALUE', 'format' => 'json', 'controller' => 'api/v1/items', 'action' => 'create'} }
    let(:service) { double('service') }
    let(:item) { double('item') }

    before(:each) do
      allow(Api::V1::Items::Create).to receive(:new).and_return service
      allow(service).to receive(:handle).and_return item
    end

    it 'creates the service' do
      expect(Api::V1::Items::Create).to receive(:new).with(params).and_return service
      post_create
    end

    it 'service handles the request' do
      expect(service).to receive(:handle).and_return item
      post_create
    end

    it 'assigns the item for rendering' do
      post_create
      expect(assigns(:item)).to eql item
    end

    it 'returns 201 - Created' do
      post_create
      expect_created
    end
  end

  describe '#update' do
    let(:patch_update) { post :update, format: :json, customer_id: 'customer_id', id: 'item_id', key: 'SOME VALUE' }
    let(:params) { {'customer_id' => 'customer_id', 'id' => 'item_id', 'key' => 'SOME VALUE', 'format' => 'json', 'controller' => 'api/v1/items', 'action' => 'update'} }
    let(:service) { double('service') }

    before(:each) do
      allow(Api::V1::Items::Update).to receive(:new).and_return service
      allow(service).to receive(:handle).and_return true
    end

    it 'creates the service' do
      expect(Api::V1::Items::Update).to receive(:new).with(params).and_return service
      patch_update
    end

    it 'service handles the request' do
      expect(service).to receive(:handle).and_return true
      patch_update
    end

    it 'returns 200 - Ok when purchase is successful' do
      patch_update
      expect_ok
    end

    it 'returns 405 - Not Allowed when item has already been purchased' do
      expect(service).to receive(:handle).and_return false
      patch_update
      expect_not_allowed
    end
  end
end
