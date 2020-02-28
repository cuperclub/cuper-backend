json.transaction_outputs do
  json.array!(
    transaction_outputs,
    partial: "api/shared/transaction_output",
    as: :transaction_output
  )
end

json.meta do
  json.total_count total_count
end
