# == Schema Information
#
# Table name: plan_companies
#
#  id         :bigint(8)        not null, primary key
#  plan_id    :bigint(8)        not null
#  company_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expired    :boolean          default(FALSE)
#

class PlanCompany < ApplicationRecord
  begin :relationships
    belongs_to :plan
    belongs_to :company
  end
end
