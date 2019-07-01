json.call(
  transaction_input,
  :id,
  :points,
  :created_at
)

json.user do
  json.partial!(
    "api/shared/user",
    user: transaction_input.user
  )
end
