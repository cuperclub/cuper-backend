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

require 'rails_helper'

RSpec.describe TransactionInput, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
