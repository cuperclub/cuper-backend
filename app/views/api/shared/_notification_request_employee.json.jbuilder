json.call(
  notification,
  :id,
)

json.user do
  json.partial!(
    "api/shared/user_basic",
    user: notification.to_user
  )
end
