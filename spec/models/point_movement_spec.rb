require "rails_helper"

RSpec.describe PointMovement, type: :model do
  it "keeps the global balance equal to the immutable movement total" do
    employee = create(:employee, role: "cashier")
    user = create(:user, points: 0)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      points_required: 3,
      total_rewards: 2)

    create(:transaction_input, user: user, employee: employee, points: 5)
    create(:transaction_output, user: user, employee: employee, promotion: promotion, points: 3)

    expect(user.reload.points).to eq(2)
    expect(described_class.where(user: user).sum(:points)).to eq(user.points)
  end

  it "does not allow posted movements to be edited or deleted" do
    input = create(:transaction_input,
      user: create(:user),
      employee: create(:employee),
      points: 5)
    movement = input.point_movement

    expect { movement.update!(points: 6) }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { movement.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it "rolls an accrual and its balance back if its ledger write fails" do
    user = create(:user, points: 0)
    employee = create(:employee)
    allow_any_instance_of(TransactionInput).to receive(:record_point_movement)
      .and_raise(ActiveRecord::RecordNotSaved)

    expect do
      TransactionInput.accrue(user: user, employee: employee, points: 5, invoice_number: nil)
    end.to raise_error(ActiveRecord::RecordNotSaved)

    expect(TransactionInput.where(user: user)).to be_empty
    expect(user.reload.points).to eq(0)
  end

  it "rolls a redemption and its inventory back if its ledger write fails" do
    employee = create(:employee, role: "cashier")
    user = create(:user, points: 10)
    promotion = create(:promotion,
      office: create(:office, company: employee.company),
      points_required: 3,
      total_rewards: 2)
    allow_any_instance_of(TransactionOutput).to receive(:record_point_movement)
      .and_raise(ActiveRecord::RecordNotSaved)

    expect do
      TransactionOutput.redeem(user: user, employee: employee, promotion: promotion, invoice_number: nil)
    end.to raise_error(ActiveRecord::RecordNotSaved)

    expect(TransactionOutput.where(user: user)).to be_empty
    expect(user.reload.points).to eq(10)
    expect(promotion.reload.total_rewards).to eq(2)
  end

  it "records adjustments idempotently and prevents negative balances" do
    user = create(:user, points: 0)
    movement, replayed = described_class.adjust!(
      user: user,
      points: 8,
      reason: "Support correction",
      reference_key: "adjustment-1"
    )

    expect(replayed).to be(false)
    expect(user.reload.points).to eq(8)
    expect(described_class.adjust!(
      user: user,
      points: 8,
      reason: "Support correction",
      reference_key: "adjustment-1"
    )).to eq([movement, true])

    expect do
      described_class.adjust!(user: user, points: -9, reason: "Bad correction", reference_key: "adjustment-2")
    end.to raise_error(ActiveRecord::RecordInvalid)
    expect do
      described_class.expire!(user: user, points: 9, reason: "Too many", reference_key: "expiry-too-large")
    end.to raise_error(ActiveRecord::RecordInvalid)
    expect(user.reload.points).to eq(8)
  end

  it "expires points and reverses a movement with a compensating event" do
    employee = create(:employee)
    user = create(:user, points: 0)
    input, saved, = TransactionInput.accrue(user: user, employee: employee, points: 10, invoice_number: nil)
    expect(saved).to be(true)

    expired, replayed = described_class.expire!(
      user: user,
      points: 3,
      reason: "Expired points",
      reference_key: "expiry-1"
    )
    expect(replayed).to be(false)
    expect(user.reload.points).to eq(7)

    expiry_reversal, replayed = described_class.reverse!(
      movement: expired,
      reason: "Restore points expired by mistake",
      reference_key: "reversal-expiry-1"
    )
    expect(replayed).to be(false)
    expect(expiry_reversal.points).to eq(3)
    expect(user.reload.points).to eq(10)

    reversal, replayed = described_class.reverse!(
      movement: input.point_movement,
      reason: "Reverse incorrect accrual",
      reference_key: "reversal-1"
    )
    expect(replayed).to be(false)
    expect(reversal.points).to eq(-10)
    expect(user.reload.points).to eq(0)
    expect(described_class.where(user: user).sum(:points)).to eq(0)
    expect(expired.kind).to eq("expiry")

    expect do
      described_class.reverse!(
        movement: input.point_movement,
        reason: "Second reversal",
        reference_key: "reversal-2"
      )
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "records a positive opening balance only for an untouched account" do
    user = create(:user, points: 0)
    movement, replayed = described_class.opening_balance!(
      user: user,
      points: 12,
      reason: "Approved account import",
      reference_key: "opening-1"
    )

    expect(replayed).to be(false)
    expect(movement.kind).to eq("opening_balance")
    expect(user.reload.points).to eq(12)
    expect(described_class.where(user: user).sum(:points)).to eq(12)
    expect do
      described_class.opening_balance!(
        user: user,
        points: 4,
        reason: "Duplicate import",
        reference_key: "opening-2"
      )
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "reconciles a projection mismatch with an auditable event without changing the balance" do
    user = create(:user, points: 8)

    expect(described_class.reconciliation_mismatches).to include([user.id, 8, 0])
    movement, replayed = described_class.reconcile!(user: user)

    expect(replayed).to be(false)
    expect(movement.kind).to eq("reconciliation")
    expect(movement.points).to eq(8)
    expect(user.reload.points).to eq(8)
    expect(described_class.where(user: user).sum(:points)).to eq(8)
    expect(described_class.reconciliation_mismatches).to be_empty
  end
end
