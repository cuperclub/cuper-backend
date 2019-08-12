json.call(
  app_setting,
  :points_by_register,
  :plan_selected_id
)

json.plan_selected do
  if app_setting.plan_selected_id
    json.partial!(
      'api/shared/plan',
      plan: Plan.find(app_setting.plan_selected_id)
    )
  end
end

json.plans do
  json.array!(
    Plan.all,
    partial: "api/shared/plan",
    as: :plan
  )
end
