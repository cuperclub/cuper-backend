# == Schema Information
#
# Table name: transaction_outputs
#
#  id            :bigint(8)        not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  points        :float
#  invoiceNumber :string
#

FactoryBot.define do
  factory :transaction_output do
    
  end
end
