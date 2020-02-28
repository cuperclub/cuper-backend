json.call(
  transaction_output,
  :id,
  :created_at
)

json.created_at(
  (transaction_output.created_at.to_f * 1000).to_i
)

json.points(
  transaction_output.promotion.points_required
)

json.promotion(
  transaction_output.promotion.title
)

json.company(
  transaction_output.employee.company.business_name
)

json.kind(
  transaction_output.class.name
)
