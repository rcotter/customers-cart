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

class Customer < ActiveRecord::Base
  include AttributeNormalizer
  include Creatable

  has_many :items, -> { order(status: :asc).order(purchased_at: :asc) }, class_name: Item.name, foreign_key: :customer_id, dependent: :destroy
  has_many :items_in_cart, -> { where(status: Item::STATUS_IN_CART) }, class_name: Item.name, foreign_key: :customer_id, dependent: :destroy

  # Cleanup dirty values - see attribute_normalizer.rb
  normalize_attribute :customer_id, with: [:strip, :blank, :downcase]
  normalize_attribute :first_name
  normalize_attribute :last_name
  normalize_attribute :date_of_birth

  validates :customer_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true, length: {minimum: 2}
  validate :validate_date_of_birth

  after_create :add_freebie # Very Railsy but maybe this hidden behaviour is not the best choice...

  # Build a customer instance with API params
  #
  # Saving this customer will result in a freebie item in their cart.
  #
  # @param [Hash] params
  # @return [Customer] customer
  def initialize(params)
    params = params.to_h
    params['customer_id'] = params.delete('id')
    super(params)
  end

  # Return full name - 'first last'
  #
  # @return [String] full name
  def full_name
    "#{first_name} #{last_name}"
  end

  # Return total of all items in the cart
  #
  # @return [Float] dollars
  def cart_total
    items_in_cart.reduce(0) { |sum, item| sum + item.amount.to_f }
  end

  private

  def validate_date_of_birth
    YyyyMmDdValidator.validate(self, :date_of_birth)
  end

  def add_freebie
    Item.create!(customer_id: id, name: 'Free Gift Card', amount: 50.00, status: Item::STATUS_PURCHASED)
  end
end
