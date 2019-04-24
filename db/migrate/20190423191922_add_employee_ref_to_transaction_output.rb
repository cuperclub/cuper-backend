class AddEmployeeRefToTransactionOutput < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_outputs, :employee, foreign_key: true
  end
end
