class RenameColumnInvoiceNumberInTransactionInput < ActiveRecord::Migration[5.2]
  def change
    rename_column :transaction_inputs, :invoiceNumber, :invoice_number
  end
end
