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

require 'rails_helper'

RSpec.describe PlanCompany, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
