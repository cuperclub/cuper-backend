# == Schema Information
#
# Table name: app_settings
#
#  id                 :bigint(8)        not null, primary key
#  show_plan          :integer
#  points_by_register :integer
#  main_employee_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class AppSetting < ApplicationRecord
end
