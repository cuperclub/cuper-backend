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
#  company_id :bigint(8)
#  lat        :float
#  long       :float
#  phone      :string
#

class Office < ApplicationRecord

  begin :relationships
    belongs_to :company
    has_many :promotions
  end

  begin :validations
    validates :name, :address, :company_id, presence: true
  end
end
