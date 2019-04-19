class CreateTransactionOutputs < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_outputs do |t|

      t.timestamps
    end
  end
end
