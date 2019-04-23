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
    belongs_to :category
    has_many :employees
  end

  begin :validations
    validates :ruc,
              :business_name,
              :category_id,
              presence: true
  end
end
