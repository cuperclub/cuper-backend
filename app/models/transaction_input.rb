# == Schema Information
#
# Table name: transaction_inputs
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint(8)
#  employee_id    :bigint(8)
#  points         :float
#  invoice_number :string
#

class TransactionInput < ApplicationRecord

  begin :relationships
    belongs_to :user
    belongs_to :employee
  end

  after_create :update_user_points


  def update_user_points
    self.user.points = self.user.points + self.points
    self.user.save()
  end

end
