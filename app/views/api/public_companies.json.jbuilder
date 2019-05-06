json.companies do
  json.array!(
    companies,
    partial: "api/shared/public_company",
    as: :company
  )
end
