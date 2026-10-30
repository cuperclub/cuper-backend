class ConvertPlanPriceToBigint < ActiveRecord::Migration[5.2]
  MAX_SAFE_VALUE = 9_007_199_254_740_991

  def up
    execute "LOCK TABLE plans IN ACCESS EXCLUSIVE MODE"
    refuse_unsafe_values

    execute <<~SQL
      ALTER TABLE plans
        ALTER COLUMN price DROP DEFAULT,
        ALTER COLUMN price TYPE bigint USING price::bigint,
        ALTER COLUMN price SET DEFAULT 0
    SQL
  end

  def down
    execute "LOCK TABLE plans IN ACCESS EXCLUSIVE MODE"
    refuse_unsafe_values

    execute <<~SQL
      ALTER TABLE plans
        ALTER COLUMN price DROP DEFAULT,
        ALTER COLUMN price TYPE double precision USING price::double precision,
        ALTER COLUMN price SET DEFAULT 0.0
    SQL
  end

  private

  def refuse_unsafe_values
    count = select_value(<<~SQL).to_i
      SELECT COUNT(*) FROM plans
      WHERE price IS NOT NULL AND (
        price::text IN ('NaN', 'Infinity', '-Infinity')
        OR price <> trunc(price)
        OR price < -#{MAX_SAFE_VALUE}
        OR price > #{MAX_SAFE_VALUE}
      )
    SQL
    return if count.zero?

    raise ActiveRecord::MigrationError,
      "Refusing to convert plan prices: fractional, non-finite, or unsafe values found (count only): #{count}"
  end
end
