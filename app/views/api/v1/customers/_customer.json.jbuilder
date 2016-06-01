json.id customer.customer_id
json.name customer.full_name
json.status (customer.approved ? 'approved' : 'denied')

json.(customer,
    :date_of_birth,
    :first_purchase_at
)

json.cart do
  json.cart_total "$#{@customer.cart_total.to_f}"

  json.items do
    json.array! @customer.items do |item|
      json.partial! '/api/v1/items/item', item: item
    end
  end
end


