# == Schema Information
#
# Table name: notifications
#
#  id           :bigint(8)        not null, primary key
#  message      :string
#  status       :string           default("pending")
#  kind         :string
#  from_user_id :bigint(8)
#  to_user_id   :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
