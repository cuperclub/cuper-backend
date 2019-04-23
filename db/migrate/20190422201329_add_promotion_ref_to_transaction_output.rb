class AddPromotionRefToTransactionOutput < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_outputs, :promotion, foreign_key: true
  end
end
