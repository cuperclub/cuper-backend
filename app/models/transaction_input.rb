# == Schema Information
#
# Table name: transaction_inputs
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint(8)
#  employee_id   :bigint(8)
#  points        :float
#  invoiceNumber :string
#

class TransactionInput < ApplicationRecord

  begin :relationships
    belongs_to :user
    belongs_to :employee
  end

end
