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

describe Item, type: :model do

  subject do
    Item.new(id: 123, customer_id: 456, item_id: 'SOME ID', name: 'SOME NAME', purchased_at: 12345656, status: 'in_cart', amount: 100)
  end

  describe 'normalization' do
    it { should normalize_attribute(:name).from('  Some Id  ').to('Some Id') }
    it { should normalize_attribute(:name).from('  ').to(nil) }

    it { should normalize_attribute(:status).from('  SOME STATUS  ').to('some status') }
    it { should normalize_attribute(:status).from('  ').to(nil) }

    it { should normalize_attribute(:amount).from('  123.45  ').to(Money.new(123.45 * 100)) }
    it { should normalize_attribute(:amount).from('  ').to(Money.new(0)) }
    it { should normalize_attribute(:amount).from(' BAD ').to(Money.new(0)) }
  end

  describe 'validations' do
    it { is_expected.to belong_to(:customer) }

    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_inclusion_of(:status).in_array(%w(in_cart purchased)).allow_nil }
  end

  it { is_expected.to callback(:set_item_id).after(:initialize) }
  it { is_expected.to callback(:set_status).after(:initialize) }

  describe '#purchasable?' do
    it 'returns true when item is in the cart' do
      expect(subject.purchasable?).to be_truthy
    end

    it 'returns false when item has already been purchased' do
      subject.status = 'purchased'
      expect(subject.purchasable?).to be_falsey
    end
  end

  describe '#purchase!' do
    let(:purchase!) { subject.purchase! }

    before(:each) do
      allow(subject).to receive(:purchasable?).and_return true
    end

    it 'raises error when not purchasable' do
      allow(subject).to receive(:purchasable?).and_return false
      expect(subject).to_not receive(:update_columns)
      expect { purchase! }.to raise_error 'Not purchasable'
    end

    it 'updates status to purchased' do
      allow(Time).to receive(:current).and_return 123456
      expect(subject).to receive(:update_columns).with(status: 'purchased', purchased_at: 123456)
      purchase!
    end
  end

  it '#set_item_id' do
    uuid = SecureRandom.uuid
    allow(SecureRandom).to receive(:uuid).and_return uuid
    subject.item_id = nil
    subject.send(:set_item_id)
    expect(subject.item_id).to eql uuid.to_s
  end

  it '#set_status' do
    subject.status = nil
    subject.send(:set_status)
    expect(subject.status).to eql 'in_cart'
  end
end
