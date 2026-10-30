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

require 'rails_helper'

RSpec.describe Setting, type: :model do
  it "belongs to a user" do
    setting = build(:setting, user: nil)

    expect(setting).not_to be_valid
    expect(setting.errors[:user]).to be_present
  end
end
