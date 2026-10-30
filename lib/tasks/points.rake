namespace :points do
  desc "Report point ledger mismatches; set APPLY=1 to record reconciliation events"
  task reconcile: :environment do
    mismatches = PointMovement.reconciliation_mismatches
    mode = ENV["APPLY"] == "1" ? "apply" : "report"
    puts "Point reconciliation (#{mode}): #{mismatches.size} mismatch(es)"

    mismatches.each do |user_id, balance, ledger_total|
      puts "user_id=#{user_id} balance=#{balance} ledger_total=#{ledger_total} difference=#{balance - ledger_total}"
    end

    if mode == "apply"
      mismatches.each { |user_id,| PointMovement.reconcile!(user: User.find(user_id)) }
      remaining = PointMovement.reconciliation_mismatches
      abort "#{remaining.size} point mismatch(es) remain; rerun the report" if remaining.any?
      puts "Reconciliation complete; balances were not changed."
    else
      puts "No balances changed. Set APPLY=1 to append reconciliation events." if mismatches.any?
    end
  end
end
