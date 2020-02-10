json.transactions do
  json.array!(
    transactions,
    partial: "api/shared/generic_transaction",
    as: :transaction
  )
end

json.meta do
  json.total_count total_count
end
