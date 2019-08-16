json.notifications do
  json.array!(
    notifications,
    partial: "api/notifications/notification",
    as: :notification
  )
end
