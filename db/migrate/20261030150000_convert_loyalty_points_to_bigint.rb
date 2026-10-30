class ConvertLoyaltyPointsToBigint < ActiveRecord::Migration[5.2]
  POINT_TABLES = %i[users transaction_inputs transaction_outputs].freeze
  MAX_SAFE_POINT_VALUE = 9_007_199_254_740_991

  def up
    execute "LOCK TABLE #{POINT_TABLES.join(', ')} IN ACCESS EXCLUSIVE MODE"
    refuse_unsafe_values

    execute <<~SQL
      ALTER TABLE users
        ALTER COLUMN points DROP DEFAULT,
        ALTER COLUMN points TYPE bigint USING points::bigint,
        ALTER COLUMN points SET DEFAULT 0
    SQL
    %i[transaction_inputs transaction_outputs].each do |table|
      execute "ALTER TABLE #{table} ALTER COLUMN points TYPE bigint USING points::bigint"
    end
  end

  def down
    execute "LOCK TABLE #{POINT_TABLES.join(', ')} IN ACCESS EXCLUSIVE MODE"
    refuse_unsafe_values

    execute <<~SQL
      ALTER TABLE users
        ALTER COLUMN points DROP DEFAULT,
        ALTER COLUMN points TYPE double precision USING points::double precision,
        ALTER COLUMN points SET DEFAULT 0.0
    SQL
    %i[transaction_inputs transaction_outputs].each do |table|
      execute "ALTER TABLE #{table} ALTER COLUMN points TYPE double precision USING points::double precision"
    end
  end

  private

  def refuse_unsafe_values
    invalid_counts = POINT_TABLES.filter_map do |table|
      count = select_value(<<~SQL).to_i
        SELECT COUNT(*) FROM #{table}
        WHERE points IS NOT NULL AND (
          points::text IN ('NaN', 'Infinity', '-Infinity')
          OR points <> trunc(points)
          OR points < -#{MAX_SAFE_POINT_VALUE}
          OR points > #{MAX_SAFE_POINT_VALUE}
        )
      SQL
      "#{table}.points: #{count}" if count.positive?
    end

    return if invalid_counts.empty?

    raise ActiveRecord::MigrationError,
      "Refusing to convert loyalty points: fractional, non-finite, or unsafe values found (counts only): #{invalid_counts.join(', ')}"
  end
end
