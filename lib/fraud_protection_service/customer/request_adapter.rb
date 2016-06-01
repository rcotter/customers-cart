class FraudProtectionService::Customer::RequestAdapter

  # Process the customer profile into a fraud protection request
  #
  # @param [Customer] customer that is valid and normalized
  # @return [Hash] service response data
  def handle(profile)
    raise 'Request expected valid' unless profile.valid?

    # This is where complex mapping could go with lots of try and &. safe navigation :)

    {
        fname: profile.first_name,
        lname: profile.last_name,
        dob: profile.date_of_birth
    }
  end
end