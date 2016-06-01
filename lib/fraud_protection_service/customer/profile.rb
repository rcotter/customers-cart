class FraudProtectionService::Customer::Profile
  include ActiveModel::Model
  include ActiveModel::Validations

  APPROVED_YES = 'yes'
  APPROVED_NO = 'no'
  APPROVED_VALS = [APPROVED_YES, APPROVED_NO]

  attr_reader :approved

  validates :approved, presence: true, inclusion: {in: APPROVED_VALS}

  # Initialize
  #
  # @param [Hash] fraud_protection_response
  def initialize(fraud_protection_response)
    @approved = fraud_protection_response['approved']
  end

  def approved?
    approved == APPROVED_YES
  end
end
