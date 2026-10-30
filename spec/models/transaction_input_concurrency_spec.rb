require 'rails_helper'

RSpec.describe TransactionInput, type: :model do
  it "does not lose concurrent point accruals" do
    employee = create(:employee)
    user = create(:user, email: "accrual-race@example.com", national_id: "accrual-race-1", points: 0)
    ready = Queue.new
    start = Queue.new

    attempts = 2.times.map do
      Thread.new do
        ready << true
        start.pop
        _, saved = described_class.accrue(
          user: User.find(user.id),
          employee: Employee.find(employee.id),
          points: 3,
          invoice_number: nil
        )
        saved
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    results = attempts.map(&:value)

    expect(results).to eq([true, true])
    expect(described_class.where(user: user).count).to eq(2)
    expect(user.reload.points).to eq(6)
  end
end
