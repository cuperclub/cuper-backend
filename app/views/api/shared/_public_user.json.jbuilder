json.call(
  user,
  :national_id
)

json.partial!(
  "api/shared/user_basic",
  user: user
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)
