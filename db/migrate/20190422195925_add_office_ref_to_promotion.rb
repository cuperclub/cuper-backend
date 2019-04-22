class AddOfficeRefToPromotion < ActiveRecord::Migration[5.2]
  def change
    add_reference :promotions, :office, foreign_key: true
  end
end
