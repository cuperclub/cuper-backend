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
#  category_id          :bigint(8)
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
