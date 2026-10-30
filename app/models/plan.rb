# == Schema Information
#
# Table name: plans
#
#  id          :bigint(8)        not null, primary key
#  price       :bigint(8)        default(0)
#  name        :string
#  information :string
#  days        :integer          default(1)
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Plan < ApplicationRecord
  MAX_SAFE_PRICE = 9_007_199_254_740_991

  begin :relationships
    has_many :plan_companies
  end

  begin :validations
    validates :price, numericality: { greater_than_or_equal_to: 0 }
    validate :price_must_be_whole_and_json_safe
  end

  private

  def price_must_be_whole_and_json_safe
    price_value = BigDecimal(price_before_type_cast.to_s, exception: false)
    return if price_value&.finite? && price_value.frac.zero? && price_value <= MAX_SAFE_PRICE

    errors.add(:price, :not_an_integer)
  end
end
