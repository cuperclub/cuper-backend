require "rails_helper"
require Rails.root.join("db/migrate/20261030150000_convert_loyalty_points_to_bigint")

RSpec.describe ConvertLoyaltyPointsToBigint do
  it "refuses to convert fractional legacy values" do
    ActiveRecord::Base.connection.transaction do
      described_class.new.migrate(:down)
      User.reset_column_information
      user = create(:user)
      user.update_column(:points, 1.5)

      expect { described_class.new.migrate(:up) }
        .to raise_error(ActiveRecord::MigrationError, /fractional, non-finite, or unsafe values/)
      expect(User.columns_hash["points"].type).to eq(:float)
      expect(user.reload.points).to eq(1.5)
      raise ActiveRecord::Rollback
    end

    User.reset_column_information
  end

  it "converts whole point values and can roll back without changing them" do
    ActiveRecord::Base.connection.transaction do
      described_class.new.migrate(:down)
      User.reset_column_information
      user = create(:user)
      user.update_column(:points, 42.0)

      described_class.new.migrate(:up)
      User.reset_column_information
      expect(User.columns_hash["points"].type).to eq(:integer)
      expect(user.reload.points).to eq(42)

      described_class.new.migrate(:down)
      User.reset_column_information
      expect(User.columns_hash["points"].type).to eq(:float)
      expect(user.reload.points).to eq(42.0)
      raise ActiveRecord::Rollback
    end

    User.reset_column_information
  end
end
