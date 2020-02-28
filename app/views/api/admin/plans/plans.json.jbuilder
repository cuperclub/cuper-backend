json.plans do
  json.array!(
    plans,
    partial: "api/shared/plan",
    as: :plan
  )
end

json.promotional_plan do
  if AppSetting.first
    json.partial!(
      'api/shared/plan',
      plan: Plan.find(AppSetting.first.plan_selected_id)
    )
  end
end
