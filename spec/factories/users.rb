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

FactoryBot.define do
  # factory :user do

  # end

  factory :user do

    name { "user" }
    email { "user@example.com" }
    password { "123123123" }
    national_id { "1" }

    trait :admin do
      email { "admin@example.com" }
      national_id { "2" }
      is_admin { true }
    end

    trait :partner do
      email { "partner@example.com" }
      national_id { "3" }
    end

  end
end
