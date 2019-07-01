json.transaction_outputs do
  json.array!(
    transaction_outputs,
    partial: "api/shared/transaction_output",
    as: :transaction_output
  )
end
