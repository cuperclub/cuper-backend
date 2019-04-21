class AddEmployeeToTransactionInputs < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_inputs, :employee, foreign_key: true
  end
end
