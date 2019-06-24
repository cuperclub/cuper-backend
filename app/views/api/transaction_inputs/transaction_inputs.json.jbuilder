json.transaction_inputs do
  binding.pry
    json.array!(
      transaction_inputs,
      partial: "api/shared/transaction_input",
      as: :transaction_input
    )
end
