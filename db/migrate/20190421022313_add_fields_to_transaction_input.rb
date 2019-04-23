class AddFieldsToTransactionInput < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_inputs, :points, :float
    add_column :transaction_inputs, :invoiceNumber, :string
  end
end
