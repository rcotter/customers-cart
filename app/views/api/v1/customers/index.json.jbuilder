json.ignore_nil! true

json.array! @customers do |c|
  json.id c.customer_id
end
