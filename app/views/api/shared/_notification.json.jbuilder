json.call(
  notification,
  :id,
  :message,
  :to_user_id,
  :from_user_id,
  :status,
  :kind,
)

json.created_at(
  (notification.created_at.to_f * 1000).to_i
)
