json.notifications do
  json.array!(
    notifications,
    partial: "api/shared/notification",
    as: :notification
  )
end

json.meta do
  json.total_count total_count
end
