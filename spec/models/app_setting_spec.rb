# == Schema Information
#
# Table name: app_settings
#
#  id                 :bigint(8)        not null, primary key
#  plan_selected_id   :integer
#  points_by_register :integer
#  main_employee_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe AppSetting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
