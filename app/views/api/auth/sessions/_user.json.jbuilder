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
  user.current_view_company_id
)

json.pending_notifications(
  user.pending_notifications
)

json.companies do
  json.array!(
    user.employees,
    partial: "api/auth/sessions/companies",
    as: :employee
  )
end

json.plan_promotion do
  # unless user.current_view_company_id
    json.partial!(
      'api/shared/plan',
      plan: Plan.find(AppSetting.last.plan_selected_id)
    )
  # end
end
