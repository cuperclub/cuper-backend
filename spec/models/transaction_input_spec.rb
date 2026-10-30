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
  it "requires a positive point amount" do
    transaction = build(:transaction_input,
      user: create(:user),
      employee: create(:employee),
      points: 0)

    expect(transaction).not_to be_valid
    expect(transaction.errors[:points]).to be_present
  end

  it "does not allow an employee to assign points to themselves" do
    employee = create(:employee, role: "cashier")
    transaction = build(:transaction_input, user: employee.user, employee: employee, points: 1)

    expect(transaction).not_to be_valid
    expect(transaction.errors[:user]).to be_present
  end
end
