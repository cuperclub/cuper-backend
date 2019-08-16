json.partial!(
  "api/shared/promotions",
  promotions: promotions
)

json.meta do
  json.total_count total_count
end
