json.plans do
  json.array!(
    plans,
    partial: "api/shared/plan",
    as: :plan
  )
end
