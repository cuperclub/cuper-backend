json.call(
  company,
  :id,
  :ruc,
  :economic_activity,
  :contributor_type,
  :legal_representative,
  :business_name,
  :logo,
  :slogan
)

json.join_at(
  (company.created_at.to_f * 1000).to_i
)

employee = company.employees.find_by_role("partner")

json.status(
  if employee
    employee.status
  end
)

json.feedback(
  if employee
    employee.feedback
  end
)
