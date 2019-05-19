json.partial!(
  "api/shared/employee",
  employee: employee
)

json.user do
  json.partial!(
    "api/shared/user",
    user: employee.user
  )
end
