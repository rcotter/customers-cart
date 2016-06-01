# == Schema Information
#
# Table name: customers
#
#  approved          :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  customer_id       :string           not null
#  date_of_birth     :date             not null
#  first_name        :string           not null
#  first_purchase_at :integer
#  id                :integer          not null, primary key
#  last_name         :string           not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Customer, type: :model do

  subject do
    Customer.new(id: 123, first_name: 'First', last_name: 'Last', date_of_birth: '1999-08-23')
  end

  describe 'normalization' do
    it { should normalize_attribute(:customer_id).from('  SOME ID  ').to('some id') }
    it { should normalize_attribute(:customer_id).from('  ').to(nil) }

    it { should normalize_attribute(:first_name).from('  First  ').to('First') }
    it { should normalize_attribute(:first_name).from('  ').to(nil) }

    it { should normalize_attribute(:last_name).from('  Last  ').to('Last') }
    it { should normalize_attribute(:last_name).from('  ').to(nil) }

    it { should normalize_attribute(:date_of_birth).from(' 1999-08-23 ').to(Date.parse('1999-08-23')) }
    it { should normalize_attribute(:date_of_birth).from('  ').to(nil) }
    it { should normalize_attribute(:date_of_birth).from('BAD').to(nil) }
  end

  describe 'validations' do
    it do
      is_expected.to have_many(:items)
                         .class_name(Item.name)
                         .dependent(:destroy)
                         .with_foreign_key(:customer_id)
      #   TODO test order
    end

    it do
      is_expected.to have_many(:items_in_cart)
                         .conditions(status: Item::STATUS_IN_CART)
                         .class_name(Item.name)
                         .dependent(:destroy)
                         .with_foreign_key(:customer_id)
    end

    it { is_expected.to validate_presence_of(:customer_id) }

    it { is_expected.to validate_presence_of(:first_name) }

    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    it 'validates date_of_birth' do
      expect(subject).to receive(:validate_date_of_birth)
      subject.validate
    end
  end

  it { is_expected.to callback(:add_freebie).after(:create) }

  it '#full_name' do
    expect(Customer.new(first_name: 'FIRST', last_name: 'LAST').full_name).to eql 'FIRST LAST'
  end

  describe '#cart_total' do
    let(:item_1) { OpenStruct.new(amount: Money.new(100)) }
    let(:item_2) { OpenStruct.new(amount: Money.new(200)) }
    let(:items) { [item_1, item_2] }

    before(:each) do
      allow(subject).to receive(:items_in_cart).and_return items
    end

    it 'returns total of items in cart' do
      expect(subject.cart_total).to eql 3.0
    end
  end

  it '#validate_date_of_birth' do
    expect(YyyyMmDdValidator).to receive(:validate).with(subject, :date_of_birth)
    subject.send(:validate_date_of_birth)
  end

  it '#add_freebie' do
    expect(Item).to receive(:create!).with(customer_id: 123, name: 'Free Gift Card', amount: 50.00, status: Item::STATUS_PURCHASED)
    subject.send(:add_freebie)
  end
end
