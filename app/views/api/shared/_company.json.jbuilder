json.call(
  company,
  :id,
  :ruc,
  :economic_activity,
  :contributor_type,
  :legal_representative,
  :business_name,
  :logo_url,
  :slogan
)

json.join_at(
  (company.created_at.to_f * 1000).to_i
)
