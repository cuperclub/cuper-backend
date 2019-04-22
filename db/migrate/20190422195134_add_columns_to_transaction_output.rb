class AddColumnsToTransactionOutput < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_outputs, :points, :float
    add_column :transaction_outputs, :invoiceNumber, :string
  end
end
