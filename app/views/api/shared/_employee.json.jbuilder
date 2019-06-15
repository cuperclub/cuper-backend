json.call(
  employee,
  :id,
  :role,
  :status,
  :feedback
)

json.user do
  json.partial!(
    "api/shared/user",
    user: employee.user
  )
end
