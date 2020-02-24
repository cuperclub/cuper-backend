json.partial!(
  "api/shared/company",
  company: company
)

json.category do
  json.partial!(
    "api/shared/category",
    category: company.category
  )
end

if company.plan_company
  plan = company.plan_company.plan
  json.plan do
    json.partial!(
      "api/shared/plan",
      plan: plan
    )
  end
end
