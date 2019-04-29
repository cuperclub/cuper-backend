json.companies do
  json.array!(
    companies,
    partial: "api/shared/company",
    as: :company
  )
end
