# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_05_174016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "points_per_dollar", default: 1
    t.boolean "active", default: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ruc"
    t.string "economic_activity"
    t.string "contributor_type"
    t.string "legal_representative"
    t.string "business_name"
    t.string "logo"
    t.string "slogan"
    t.boolean "active", default: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_companies_on_category_id"
  end

  create_table "employees", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id"
    t.string "role"
    t.boolean "active", default: false
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "email"
    t.string "address"
    t.boolean "active", default: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_offices_on_company_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description"
    t.string "terms"
    t.string "image"
    t.string "background"
    t.integer "total_rewards", default: 0
    t.integer "points_required", default: 0
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "unlimited", default: false
    t.bigint "office_id"
    t.index ["office_id"], name: "index_promotions_on_office_id"
  end

  create_table "transaction_inputs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "employee_id"
    t.float "points"
    t.string "invoice_number"
    t.index ["employee_id"], name: "index_transaction_inputs_on_employee_id"
    t.index ["user_id"], name: "index_transaction_inputs_on_user_id"
  end

  create_table "transaction_outputs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "points"
    t.string "invoice_number"
    t.bigint "promotion_id"
    t.bigint "employee_id"
    t.bigint "user_id"
    t.index ["employee_id"], name: "index_transaction_outputs_on_employee_id"
    t.index ["promotion_id"], name: "index_transaction_outputs_on_promotion_id"
    t.index ["user_id"], name: "index_transaction_outputs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "national_id"
    t.boolean "is_admin", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "companies", "categories"
  add_foreign_key "employees", "companies"
  add_foreign_key "employees", "users"
  add_foreign_key "offices", "companies"
  add_foreign_key "promotions", "offices"
  add_foreign_key "transaction_inputs", "employees"
  add_foreign_key "transaction_inputs", "users"
  add_foreign_key "transaction_outputs", "employees"
  add_foreign_key "transaction_outputs", "promotions"
  add_foreign_key "transaction_outputs", "users"
end
