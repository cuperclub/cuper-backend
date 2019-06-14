json.extract!(
  user,
  :id,
  :name,
  :email,
  :image_url,
  :national_id,
  :is_partner,
  :is_cashier
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)
