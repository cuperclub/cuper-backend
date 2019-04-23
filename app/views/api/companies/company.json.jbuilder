json.company do
  json.partial!(
    'api/companies/company',
    company: company
  )
  json.category do
    json.partial!(
      "api/categories/category",
      category: company.category
    )
  end
end
