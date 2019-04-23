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
#  user_id       :bigint(8)
#

require 'rails_helper'

RSpec.describe TransactionOutput, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
