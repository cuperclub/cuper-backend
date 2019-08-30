json.call(
  transaction_input,
  :id,
  :points
)

json.created_at(
  (transaction_input.created_at.to_f * 1000).to_i
)

json.company(
  transaction_input.employee.company.business_name
)
