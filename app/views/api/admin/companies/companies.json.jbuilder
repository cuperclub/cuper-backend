json.companies do
  json.array!(
    companies,
    partial: "company",
    as: :company
  )
end
