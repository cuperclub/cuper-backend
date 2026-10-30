require 'rails_helper'

RSpec.describe TransactionOutput, type: :model do
  it "accepts limited promotions with more than one reward remaining" do
    employee = create(:employee)
    user = create(:user, email: "stock@example.com", national_id: "stock-1", points: 20)
    promotion = create(:promotion, office: create(:office, company: employee.company), total_rewards: 3)

    transaction = build(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 1)

    expect(transaction).to be_valid
  end

  it "rejects limited promotions when no rewards remain" do
    employee = create(:employee)
    user = create(:user, email: "soldout@example.com", national_id: "soldout-1", points: 20)
    promotion = create(:promotion, office: create(:office, company: employee.company), total_rewards: 0)

    transaction = build(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 1)

    expect(transaction).not_to be_valid
  end

  it "accepts unlimited promotions regardless of the stored reward count" do
    employee = create(:employee)
    user = create(:user, email: "unlimited@example.com", national_id: "unlimited-1", points: 20)
    promotion = create(:promotion, office: create(:office, company: employee.company), total_rewards: 0, unlimited: true)

    transaction = build(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 1)

    expect(transaction).to be_valid
  end

  it "treats a null legacy balance as zero when checking a redemption" do
    employee = create(:employee)
    user = create(:user, email: "null-redemption-balance@example.com", national_id: "null-redemption-balance", points: nil)
    promotion = create(:promotion, office: create(:office, company: employee.company), points_required: 1)

    transaction = build(:transaction_output,
      user: user,
      employee: employee,
      promotion: promotion,
      points: 1)

    expect(transaction).not_to be_valid
    expect(transaction.errors[:points]).to be_present
  end
end
