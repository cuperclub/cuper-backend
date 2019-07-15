json.call(
  app_setting,
  :points_by_register,
  :main_employee_id
)

json.plan_selected do
  if Plan.first
    json.partial!(
      'api/shared/plan',
      plan: Plan.first
    )
  end
end
