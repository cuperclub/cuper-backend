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

FactoryBot.define do
  factory :transaction_input do
    
  end
end
