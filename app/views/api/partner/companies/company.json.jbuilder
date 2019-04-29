json.partial!(
  "api/shared/company",
  company: company
)

json.category do
  json.partial!(
    "api/shared/category",
    category: company.category
  )
end
