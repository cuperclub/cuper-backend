json.companies do
  json.array!(
    companies,
    partial: "api/shared/admin_company",
    as: :company
  )
end
