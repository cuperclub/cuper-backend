require "rails_helper"
require Rails.root.join("db/migrate/20261030160000_convert_plan_price_to_bigint")

RSpec.describe ConvertPlanPriceToBigint do
  it "refuses to convert fractional legacy prices" do
    ActiveRecord::Base.connection.transaction do
      described_class.new.migrate(:down)
      Plan.reset_column_information
      plan = create(:plan)
      plan.update_column(:price, 1.5)

      expect { described_class.new.migrate(:up) }
        .to raise_error(ActiveRecord::MigrationError, /fractional, non-finite, or unsafe values/)
      expect(Plan.columns_hash["price"].type).to eq(:float)
      expect(plan.reload.price).to eq(1.5)
      raise ActiveRecord::Rollback
    end

    Plan.reset_column_information
  end

  it "converts whole prices and can roll back without changing them" do
    ActiveRecord::Base.connection.transaction do
      described_class.new.migrate(:down)
      Plan.reset_column_information
      plan = create(:plan, price: 29)

      described_class.new.migrate(:up)
      Plan.reset_column_information
      expect(Plan.columns_hash["price"].type).to eq(:integer)
      expect(plan.reload.price).to eq(29)

      described_class.new.migrate(:down)
      Plan.reset_column_information
      expect(Plan.columns_hash["price"].type).to eq(:float)
      expect(plan.reload.price).to eq(29.0)
      raise ActiveRecord::Rollback
    end

    Plan.reset_column_information
  end
end
