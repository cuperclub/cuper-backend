json.employees do
  json.array!(
    employees,
    partial: "api/shared/employee",
    as: :employee
  )
end
