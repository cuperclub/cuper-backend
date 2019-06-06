if @success.present?
  json.success @success
end

json.data do
  json.partial!("api/auth/sessions/user", user: @resource)
end
