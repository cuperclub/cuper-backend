json.company do
  json.partial!(
    'api/companies/company',
    company: company
  )
end
