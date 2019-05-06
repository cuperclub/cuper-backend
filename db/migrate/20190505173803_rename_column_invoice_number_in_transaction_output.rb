class RenameColumnInvoiceNumberInTransactionOutput < ActiveRecord::Migration[5.2]
  def change
    rename_column :transaction_outputs, :invoiceNumber, :invoice_number
  end
end
