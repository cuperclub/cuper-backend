class AddFeedbackToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :feedback, :text
  end
end
