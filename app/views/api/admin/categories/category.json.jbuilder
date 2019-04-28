json.category do
  json.partial!(
    'api/admin/categories/category',
    category: category
  )
end
