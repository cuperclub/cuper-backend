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
#  user_id              :bigint(8)
#

class Company < ApplicationRecord

  begin :relationships
    belongs_to :user
  end

  begin :validations
    validates :ruc,
              :business_name,
              presence: true
  end
end
