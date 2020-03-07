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

  json.expired_plan company.plan_company.expired

  json.expired_plan_date ((company.plan_company.start_date + (company.plan_company.plan.days * 86400)).to_f * 1000).to_i
end
