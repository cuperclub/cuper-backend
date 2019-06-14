json.extract!(
  user,
  :id,
  :name,
  :image,
  :email,
  :national_id,
  :is_partner,
  :is_cashier,
  :points
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)

json.companies do
  json.array!(
    user.employees,
    partial: "api/auth/sessions/companies",
    as: :employee
  )
end
