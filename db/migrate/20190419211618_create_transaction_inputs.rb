class CreateTransactionInputs < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_inputs do |t|

      t.timestamps
    end
  end
end
