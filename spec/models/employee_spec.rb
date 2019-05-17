# == Schema Information
#
# Table name: employees
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#  company_id :bigint(8)
#  role       :string
#  feedback   :text
#  status     :string           default("pending")
#

require 'rails_helper'

RSpec.describe Employee, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
