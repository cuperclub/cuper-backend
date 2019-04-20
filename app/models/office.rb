# == Schema Information
#
# Table name: offices
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  email      :string
#  address    :string
#  active     :boolean          default(FALSE)
#

class Office < ApplicationRecord
end
