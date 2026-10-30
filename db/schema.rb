# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_30_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "app_settings", force: :cascade do |t|
    t.integer "plan_selected_id"
    t.integer "points_by_register"
    t.integer "main_employee_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.integer "points_per_dollar", default: 1
    t.boolean "active", default: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.bigint "company_id"
    t.string "role"
    t.text "feedback"
    t.string "status", default: "pending"
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "message"
    t.string "status", default: "pending"
    t.string "kind"
    t.bigint "from_employee_id"
    t.bigint "from_user_id"
    t.bigint "to_user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["from_employee_id"], name: "index_notifications_on_from_employee_id"
    t.index ["from_user_id"], name: "index_notifications_on_from_user_id"
    t.index ["to_user_id"], name: "index_notifications_on_to_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "email"
    t.string "address"
    t.boolean "active", default: false
    t.bigint "company_id"
    t.float "lat"
    t.float "long"
    t.string "phone"
    t.index ["company_id"], name: "index_offices_on_company_id"
  end

  create_table "plan_companies", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "expired", default: false
    t.index ["company_id"], name: "index_plan_companies_on_company_id"
    t.index ["plan_id"], name: "index_plan_companies_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "price", default: 0
    t.string "name"
    t.string "information"
    t.integer "days", default: 1
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "point_movements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "transaction_input_id"
    t.bigint "transaction_output_id"
    t.bigint "points", null: false
    t.string "kind", null: false
    t.string "idempotency_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "reference_key"
    t.string "reason"
    t.bigint "reversal_of_id"
    t.index ["reversal_of_id"], name: "index_point_movements_on_reversal_of_id", unique: true
    t.index ["transaction_input_id"], name: "index_point_movements_on_transaction_input_id", unique: true
    t.index ["transaction_output_id"], name: "index_point_movements_on_transaction_output_id", unique: true
    t.index ["user_id", "idempotency_key"], name: "index_point_movements_on_user_and_idempotency_key", unique: true, where: "(idempotency_key IS NOT NULL)"
    t.index ["user_id", "reference_key"], name: "index_point_movements_on_user_and_reference_key", unique: true, where: "(reference_key IS NOT NULL)"
    t.index ["user_id"], name: "index_point_movements_on_user_id"
    t.check_constraint "(kind::text = 'reversal'::text) = (reversal_of_id IS NOT NULL)", name: "point_movements_reversal_reference"
    t.check_constraint "(kind::text = ANY (ARRAY['accrual'::character varying, 'redemption'::character varying]::text[])) OR COALESCE(length(TRIM(BOTH FROM reference_key)), 0) > 0 AND COALESCE(length(TRIM(BOTH FROM reason)), 0) > 0", name: "point_movements_manual_event_metadata"
    t.check_constraint "kind::text = 'accrual'::text AND points >= 0 OR (kind::text = ANY (ARRAY['redemption'::character varying::text, 'expiry'::character varying::text])) AND points < 0 OR (kind::text = ANY (ARRAY['adjustment'::character varying::text, 'reversal'::character varying::text, 'reconciliation'::character varying::text])) AND points <> 0 OR kind::text = 'opening_balance'::text AND points > 0", name: "point_movements_kind_matches_points"
    t.check_constraint "kind::text = 'accrual'::text AND transaction_input_id IS NOT NULL AND transaction_output_id IS NULL OR kind::text = 'redemption'::text AND transaction_output_id IS NOT NULL AND transaction_input_id IS NULL OR (kind::text <> ALL (ARRAY['accrual'::character varying::text, 'redemption'::character varying::text])) AND transaction_input_id IS NULL AND transaction_output_id IS NULL", name: "point_movements_valid_source"
    t.check_constraint "kind::text = ANY (ARRAY['accrual'::character varying::text, 'redemption'::character varying::text, 'expiry'::character varying::text, 'adjustment'::character varying::text, 'reversal'::character varying::text, 'opening_balance'::character varying::text, 'reconciliation'::character varying::text])", name: "point_movements_valid_kind"
  end

  create_table "promotions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.string "description"
    t.string "terms"
    t.string "image"
    t.string "background"
    t.integer "total_rewards", default: 0
    t.integer "points_required", default: 0
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.boolean "unlimited", default: false
    t.bigint "office_id"
    t.index ["office_id"], name: "index_promotions_on_office_id"
  end

  create_table "settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "current_company"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "transaction_inputs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.bigint "employee_id"
    t.bigint "points"
    t.string "invoice_number"
    t.index ["employee_id"], name: "index_transaction_inputs_on_employee_id"
    t.index ["user_id"], name: "index_transaction_inputs_on_user_id"
  end

  create_table "transaction_outputs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "points"
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
    t.datetime "reset_password_sent_at", precision: nil
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "national_id"
    t.boolean "is_admin", default: false
    t.boolean "active", default: true
    t.bigint "points", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "companies", "categories"
  add_foreign_key "employees", "companies"
  add_foreign_key "employees", "users"
  add_foreign_key "offices", "companies"
  add_foreign_key "point_movements", "point_movements", column: "reversal_of_id"
  add_foreign_key "point_movements", "transaction_inputs"
  add_foreign_key "point_movements", "transaction_outputs"
  add_foreign_key "point_movements", "users"
  add_foreign_key "promotions", "offices"
  add_foreign_key "transaction_inputs", "employees"
  add_foreign_key "transaction_inputs", "users"
  add_foreign_key "transaction_outputs", "employees"
  add_foreign_key "transaction_outputs", "promotions"
  add_foreign_key "transaction_outputs", "users"
end
