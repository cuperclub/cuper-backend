# == Schema Information
#
# Table name: settings
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)        not null
#  current_company :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Setting < ApplicationRecord
  begin :relationships
    belongs_to :user
  end
end
