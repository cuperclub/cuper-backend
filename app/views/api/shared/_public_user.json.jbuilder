json.call(
  user,
  :id,
  :name,
  :email,
  :image_url,
  :national_id
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)
