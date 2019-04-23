class AddColumnsToPromotion < ActiveRecord::Migration[5.2]
  def change
    add_column :promotions, :title, :string
    add_column :promotions, :description, :string
    add_column :promotions, :terms, :string
    add_column :promotions, :image, :string
    add_column :promotions, :background, :string
    add_column :promotions, :totalRewards, :integer, default: 0
    add_column :promotions, :pointsRequired, :integer, default: 0
    add_column :promotions, :startAt, :datetime
    add_column :promotions, :endAt, :datetime
    add_column :promotions, :unlimited, :boolean, default: false
  end
end
