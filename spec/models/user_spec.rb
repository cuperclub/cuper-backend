# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  allow_password_change  :boolean          default(FALSE)
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  nickname               :string
#  image                  :string
#  email                  :string
#  tokens                 :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  national_id            :string
#  is_admin               :boolean          default(FALSE)
#  active                 :boolean          default(TRUE)
#  points                 :float            default(0.0)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it "missing obligatory fields is invalid" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is an employee only after an employee membership is approved" do
    user = create(:user)
    employee = create(:employee, user: user)

    expect(user.is_employee).to be false

    employee.update!(status: "approved")

    expect(user.is_employee).to be true
  end

  it "does not select a company without an approved membership" do
    user = create(:user)
    employee = create(:employee, user: user, status: "pending")
    user.create_setting!(current_company: employee.company_id)

    expect(user.current_view_company_id).to be_nil
  end

  it "ignores a saved company that the user is no longer approved for" do
    user = create(:user)
    approved = create(:employee, user: user, status: "approved")
    other_company = create(:company, ruc: "987654321")
    user.create_setting!(current_company: other_company.id)

    expect(user.current_view_company_id).to eq(approved.company_id)
  end
end
