# == Schema Information
#
# Table name: transaction_outputs
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  points        :float
#  invoiceNumber :string
#  promotion_id  :bigint(8)
#  employee_id   :bigint(8)
#

class TransactionOutput < ApplicationRecord
  begin :relationships
    belongs_to :promotion
    belongs_to :employee
  end
end
