json.users do
  json.array!(
    users,
    partial: "api/shared/admin_user",
    as: :user
  )
end

json.meta do
  json.total_count total_count
end
