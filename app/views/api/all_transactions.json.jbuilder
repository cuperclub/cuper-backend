json.transaction_inputs do
  json.array!(
    inputs,
    partial: "api/shared/simple_transaction_input",
    as: :transaction_input
  )
end

json.transaction_outputs do
  json.array!(
    outputs,
    partial: "api/shared/simple_transaction_output",
    as: :transaction_output
  )
end
