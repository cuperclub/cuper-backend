# == Schema Information
#
# Table name: companies
#
#  id                   :bigint(8)        not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ruc                  :string
#  economic_activity    :string
#  contributor_type     :string
#  legal_representative :string
#  business_name        :string
#  logo                 :string
#  slogan               :string
#  active               :boolean          default(FALSE)
#  category_id          :bigint(8)
#

class Company < ApplicationRecord

  begin :relationships
    has_many :employees
    has_many :users, through: :employees
    has_many :offices
    has_many :promotions, through: :offices
    belongs_to :category
  end

  begin :validations
    validates :ruc, presence: true, uniqueness: true
    validates :business_name, :economic_activity, :legal_representative, :category_id, presence: true
  end
end
