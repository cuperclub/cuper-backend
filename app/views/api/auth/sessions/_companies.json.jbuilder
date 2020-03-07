json.call(
  employee,
  :status,
  :role
)

json.id(
  employee.company.id
)

json.name(
  employee.company.business_name
)

json.join_at(
  (employee.company.created_at.to_f * 1000).to_i
)

json.logo_url(
  employee.company.logo_url
)

json.expired_plan(
  if employee.company && employee.company.plan_company
    employee.company.plan_company.expired
  else
    nil
  end
)

json.expired_plan_date(
  if employee.company && employee.company.plan_company
    ((employee.company.plan_company.start_date + (employee.company.plan_company.plan.days * 86400)).to_f * 1000).to_i
  else
    nil
  end
)
