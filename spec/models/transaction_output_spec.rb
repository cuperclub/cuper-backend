# == Schema Information
#
# Table name: transaction_outputs
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  points         :bigint(8)
#  invoice_number :string
#  promotion_id   :bigint(8)
#  employee_id    :bigint(8)
#  user_id        :bigint(8)
#

require 'rails_helper'

RSpec.describe TransactionOutput, type: :model do
  it "rejects a redemption that would make the user's balance negative" do
    employee = create(:employee, role: "cashier")
    user = create(:user, points: 2)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      points_required: 3)
    transaction = build(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 3)

    expect(transaction).not_to be_valid
    expect(transaction.errors[:points]).to be_present
  end

  it "does not allow posted redemption amounts to be edited" do
    employee = create(:employee, role: "cashier")
    user = create(:user, points: 10)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      points_required: 3,
      total_rewards: 2)
    transaction = create(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 3)

    expect(transaction.update(points: 4)).to be(false)
    expect(transaction.reload.points).to eq(3)
  end

end
