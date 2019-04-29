json.categories do
  json.array!(
    categories,
    partial: "api/shared/category",
    as: :category
  )
end
