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
#  active     :boolean          default(FALSE)
#

class Employee < ApplicationRecord
end
