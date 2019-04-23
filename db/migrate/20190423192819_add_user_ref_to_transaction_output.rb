class AddUserRefToTransactionOutput < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_outputs, :user, foreign_key: true
  end
end
