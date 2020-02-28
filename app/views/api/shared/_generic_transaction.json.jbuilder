if transaction.has_attribute?(:promotion_id)
  json.partial!(
    "api/shared/simple_transaction_output",
    transaction_output: transaction
  )
else
  json.partial!(
    "api/shared/simple_transaction_input",
    transaction_input: transaction
  )
end
