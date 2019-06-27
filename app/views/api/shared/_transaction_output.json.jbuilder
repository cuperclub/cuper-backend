json.call(
  transaction_output,
  :id,
  :created_at
)

json.user do
  json.partial!(
    "api/shared/user",
    user: transaction_output.user
  )
end

json.promotion do
  json.partial!(
    "api/shared/promotion",
    promotion: transaction_output.promotion
  )
end
