json.ignore_nil! true

json.partial! '/api/v1/customers/customer', customer: @customer, fraud_profile: @fraud_profile
