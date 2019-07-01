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
