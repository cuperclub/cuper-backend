json.call(
  user,
  :id,
  :name,
  :image,
  :email,
  :national_id,
  :is_partner,
  :is_cashier,
  :is_admin,
  :points
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)