require 'rails_helper'

RSpec.describe TransactionOutput, type: :model do
  it "serializes concurrent attempts to spend the last points and reward" do
    employee = create(:employee)
    user = create(:user, email: "race@example.com", national_id: "race-1", points: 0)
    TransactionInput.accrue(user: user, employee: employee, points: 10, invoice_number: nil)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      total_rewards: 1,
      points_required: 7)
    ready = Queue.new
    start = Queue.new

    attempts = 2.times.map do
      Thread.new do
        ready << true
        start.pop
        _, saved = described_class.redeem(
          user: User.find(user.id),
          employee: Employee.find(employee.id),
          promotion: Promotion.find(promotion.id),
          invoice_number: nil
        )
        saved
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    results = attempts.map(&:value)

    expect(results.count(true)).to eq(1)
    expect(results.count(false)).to eq(1)
    expect(described_class.where(user: user, promotion: promotion).count).to eq(1)
    expect(user.reload.points).to eq(3)
    expect(PointMovement.where(user: user).sum(:points)).to eq(3)
    expect(promotion.reload.total_rewards).to eq(0)
  end

  it "replays concurrent redemptions with the same key once" do
    employee = create(:employee)
    user = create(:user, email: "redeem-idempotency@example.com", national_id: "redeem-idempotency-1", points: 0)
    TransactionInput.accrue(user: user, employee: employee, points: 10, invoice_number: nil)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      total_rewards: 1,
      points_required: 7)
    ready = Queue.new
    start = Queue.new

    attempts = 2.times.map do
      Thread.new do
        ready << true
        start.pop
        _, saved, replayed = described_class.redeem(
          user: User.find(user.id),
          employee: Employee.find(employee.id),
          promotion: Promotion.find(promotion.id),
          invoice_number: "same-invoice",
          idempotency_key: "same-redemption-key"
        )
        [saved, replayed]
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    results = attempts.map(&:value)

    expect(results.count { |saved, _| saved }).to eq(2)
    expect(results.count { |_, replayed| replayed }).to eq(1)
    expect(described_class.where(user: user, promotion: promotion).count).to eq(1)
    expect(PointMovement.where(user: user).count).to eq(2)
    expect(user.reload.points).to eq(3)
    expect(PointMovement.where(user: user).sum(:points)).to eq(3)
    expect(promotion.reload.total_rewards).to eq(0)
  end
end
