class AddUserToTransactionInputs < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_inputs, :user, foreign_key: true
  end
end
