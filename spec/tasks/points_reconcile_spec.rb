require "rails_helper"

Rails.application.load_tasks

RSpec.describe "points:reconcile" do
  before { Rake::Task["points:reconcile"].reenable }

  it "reports mismatches without changing balances or ledger rows" do
    user = create(:user, points: 8)
    output = run_task

    expect(output).to include("Point reconciliation (report): 1 mismatch(es)")
    expect(output).to include("user_id=#{user.id} balance=8 ledger_total=0 difference=8")
    expect(user.reload.points).to eq(8)
    expect(PointMovement.where(user: user)).to be_empty
  end

  it "appends a reconciliation event without changing the balance when APPLY=1" do
    user = create(:user, points: 8)
    output = run_task(apply: true)

    expect(output).to include("Point reconciliation (apply): 1 mismatch(es)")
    expect(output).to include("Reconciliation complete; balances were not changed.")

    expect(user.reload.points).to eq(8)
    expect(PointMovement.where(user: user).sum(:points).to_i).to eq(8)
    expect(PointMovement.reconciliation_mismatches).to be_empty
  end

  def run_task(apply: false)
    previous_apply = ENV["APPLY"]
    ENV["APPLY"] = apply ? "1" : nil
    original_stdout = $stdout
    output = StringIO.new
    $stdout = output
    Rake::Task["points:reconcile"].invoke
    output.string
  ensure
    ENV["APPLY"] = previous_apply
    $stdout = original_stdout
  end
end
