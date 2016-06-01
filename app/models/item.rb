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

class Item < ActiveRecord::Base
  include AttributeNormalizer

  belongs_to :customer

  STATUS_IN_CART = 'in_cart'
  STATUS_PURCHASED = 'purchased'
  STATUSES = [STATUS_IN_CART, STATUS_PURCHASED].freeze

  monetize :amount_cents

  # Cleanup dirty values - see attribute_normalizer.rb
  normalize_attribute :name
  normalize_attribute :status, with: [:strip, :blank, :downcase]
  normalize_attribute :amount, with: [:strip, :blank, :float]

  validates :amount_cents, presence: true, numericality: {greater_than: 0, integer_only: true}
  validates :name, presence: true
  validates :status, allow_nil: true, inclusion: {in: STATUSES, message: "expected #{STATUS_IN_CART} or #{STATUS_PURCHASED}"}

  after_initialize :set_item_id, :set_status

  # Is this item able to be purchased
  #
  # @return [Boolean] true/false
  def purchasable?
    status == STATUS_IN_CART
  end

  # Purchase this item
  #
  # Raises error unless `purchasable? == true`
  def purchase!
    raise 'Not purchasable' unless purchasable?

    update_columns(status: STATUS_PURCHASED, purchased_at: Time.current.to_i)
  end

  private

  def set_item_id
    self.item_id ||= SecureRandom.uuid.to_s
  end

  def set_status
    self.status ||= STATUS_IN_CART
  end
end
