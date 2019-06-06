json.extract!(
  user,
  :id,
  :uid,
  :name,
  :image,
  :email,
  :nickname,
  :provider
)

json.is_partner(
  user.is_partner
)

json.is_cashier(
  user.is_cashier
)
