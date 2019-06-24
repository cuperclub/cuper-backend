json.extract!(
  user,
  :id,
  :name,
  :email,
  :image_url,
  :national_id,
  :is_partner,
  :is_cashier,
  :is_admin,
  :points
)

json.join_at(
  (user.created_at.to_f * 1000).to_i
)

json.current_company_id(
  if user.setting && user.setting.current_company
    user.setting.current_company
  else
    if user.employees.first
      user.employees.first.company.id
    end
  end
)

json.companies do
  json.array!(
    user.employees,
    partial: "api/auth/sessions/companies",
    as: :employee
  )
end
