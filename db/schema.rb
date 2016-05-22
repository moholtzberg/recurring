# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160424175208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_item_prices", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "item_id"
    t.float    "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string  "account_type"
    t.string  "name"
    t.string  "stripe_customer_id"
    t.string  "number"
    t.string  "email"
    t.string  "ship_to_address_1"
    t.string  "ship_to_address_2"
    t.string  "ship_to_city"
    t.string  "ship_to_state"
    t.string  "ship_to_zip"
    t.string  "ship_to_phone"
    t.string  "ship_to_fax"
    t.string  "bill_to_address_1"
    t.string  "bill_to_address_2"
    t.string  "bill_to_city"
    t.string  "bill_to_state"
    t.string  "bill_to_zip"
    t.string  "bill_to_phone"
    t.string  "bill_to_fax"
    t.boolean "active"
    t.integer "group_id"
  end

  create_table "assets", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "type"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.integer  "attachment_file_size"
    t.integer  "position"
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.datetime "attachment_updated_at"
    t.text     "alt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name"
    t.boolean  "active"
    t.boolean  "preferred"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prefix"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "menu_id"
    t.string  "name"
    t.string  "slug"
    t.text    "description"
    t.boolean "show_in_menu"
    t.boolean "active"
  end

  add_index "categories", ["id"], name: "category_id_ix", using: :btree
  add_index "categories", ["parent_id"], name: "category_parent_id_ix", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer "account_id"
    t.integer "payment_plan_id"
    t.integer "invoice_id"
    t.float   "line_number"
    t.float   "amount"
    t.float   "quantity"
    t.date    "from_date"
    t.date    "to_date"
    t.text    "description"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.string  "number"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer "account_id"
    t.string  "stripe_customer_id"
    t.string  "stripe_card_id"
    t.string  "expiration"
  end

  create_table "equipment", force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.integer "payment_plan_id"
    t.string  "number"
    t.string  "serial"
    t.string  "make"
    t.string  "model"
  end

  create_table "group_item_prices", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "item_id"
    t.float    "price"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_item_prices", ["group_id"], name: "index_group_item_prices_on_group_id", using: :btree
  add_index "group_item_prices", ["item_id"], name: "index_group_item_prices_on_item_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "group_type"
    t.string   "name"
    t.string   "slug"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_histories", force: :cascade do |t|
    t.integer  "nb_imported"
    t.integer  "nb_failed"
    t.integer  "nb_in_queue"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "invoice_payment_applications", force: :cascade do |t|
    t.integer "payment_id"
    t.integer "invoice_id"
  end

  add_index "invoice_payment_applications", ["invoice_id"], name: "index_invoice_payment_applications_on_invoice_id", using: :btree
  add_index "invoice_payment_applications", ["payment_id"], name: "index_invoice_payment_applications_on_payment_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "account_id"
    t.text     "number"
    t.date     "date"
    t.float    "total"
    t.integer  "order_id"
    t.datetime "due_date"
  end

  create_table "item_categories", force: :cascade do |t|
    t.integer "category_id"
    t.integer "item_id"
  end

  add_index "item_categories", ["category_id"], name: "item_category_category_id_ix", using: :btree
  add_index "item_categories", ["item_id"], name: "item_category_item_id_ix", using: :btree

  create_table "item_properties", force: :cascade do |t|
    t.integer "item_id"
    t.string  "key"
    t.string  "value"
    t.integer "order"
    t.boolean "active"
  end

  create_table "item_types", force: :cascade do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "item_vendor_prices", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "vendor_id"
    t.float    "price"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "vendor_item_number"
  end

  create_table "items", force: :cascade do |t|
    t.integer  "item_type_id"
    t.integer  "category_id"
    t.integer  "model_id"
    t.boolean  "is_serialized"
    t.string   "number",                       null: false
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.float    "price"
    t.float    "sale_price"
    t.float    "cost_price"
    t.float    "weight"
    t.float    "height"
    t.float    "width"
    t.float    "length"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "brand_id"
    t.boolean  "active",        default: true, null: false
  end

  add_index "items", ["id"], name: "item_id_ix", using: :btree

  create_table "line_item_fulfillments", force: :cascade do |t|
    t.integer  "order_line_item_id"
    t.integer  "invoice_id"
    t.integer  "quantity_fulfilled"
    t.datetime "date"
  end

  create_table "line_item_shipments", force: :cascade do |t|
    t.integer  "order_line_item_id"
    t.integer  "shipment_id"
    t.integer  "quantity_shipped"
    t.datetime "date"
  end

  add_index "line_item_shipments", ["id"], name: "line_item_shipment_id_ix", using: :btree
  add_index "line_item_shipments", ["order_line_item_id"], name: "line_item_shipment_order_line_item_id_ix", using: :btree
  add_index "line_item_shipments", ["shipment_id"], name: "line_item_shipment_shipment_id_ix", using: :btree

  create_table "makes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meter_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meter_readings", force: :cascade do |t|
    t.integer "meter_id"
    t.float   "display"
    t.string  "source"
    t.boolean "is_valid"
    t.boolean "is_estimate"
  end

  create_table "meters", force: :cascade do |t|
    t.integer "equipment_id"
    t.string  "meter_type"
  end

  create_table "models", force: :cascade do |t|
    t.integer  "make_id"
    t.string   "number"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "order_line_number"
    t.integer  "item_id"
    t.float    "quantity"
    t.float    "price"
    t.float    "discount"
    t.text     "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "quantity_canceled"
    t.integer  "quantity_shipped",   default: 0
    t.integer  "quantity_fulfilled", default: 0
  end

  add_index "order_line_items", ["id"], name: "order_line_item_id_ix", using: :btree
  add_index "order_line_items", ["item_id"], name: "order_line_item_item_id_ix", using: :btree
  add_index "order_line_items", ["order_id"], name: "order_line_item_order_id_ix", using: :btree

  create_table "order_payment_applications", force: :cascade do |t|
    t.integer  "payment_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_payment_applications", ["order_id"], name: "index_order_payment_applications_on_order_id", using: :btree
  add_index "order_payment_applications", ["payment_id"], name: "index_order_payment_applications_on_payment_id", using: :btree

  create_table "order_shipping_methods", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "number"
    t.integer  "account_id"
    t.integer  "contact_id"
    t.integer  "sales_rep_id"
    t.datetime "date"
    t.datetime "due_date"
    t.datetime "completed_at"
    t.boolean  "canceled"
    t.boolean  "locked"
    t.string   "po_number"
    t.string   "ip_address"
    t.string   "ship_to_account_name"
    t.string   "ship_to_address_1"
    t.string   "ship_to_address_2"
    t.string   "ship_to_attention"
    t.string   "ship_to_city"
    t.string   "ship_to_state"
    t.string   "ship_to_zip"
    t.string   "ship_to_phone"
    t.string   "bill_to_account_name"
    t.string   "bill_to_address_1"
    t.string   "bill_to_address_2"
    t.string   "bill_to_attention"
    t.string   "bill_to_city"
    t.string   "bill_to_state"
    t.string   "bill_to_zip"
    t.string   "bill_to_phone"
    t.text     "notes"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "orders", ["account_id"], name: "order_customer_id_ix", using: :btree
  add_index "orders", ["id"], name: "order_id_ix", using: :btree

  create_table "payment_methods", force: :cascade do |t|
    t.string  "name"
    t.boolean "active"
  end

  create_table "payment_plan_templates", force: :cascade do |t|
    t.text  "name"
    t.float "amount"
  end

  create_table "payment_plans", force: :cascade do |t|
    t.text    "name"
    t.integer "account_id"
    t.integer "payment_plan_template_id"
    t.date    "billing_start"
    t.date    "billing_end"
    t.date    "last_billing_date"
    t.float   "amount"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "account_id"
    t.integer "payment_method_id"
    t.integer "credit_card_id"
    t.float   "amount"
    t.string  "stripe_charge_id"
  end

  create_table "reciepts", force: :cascade do |t|
    t.integer "payment_plan_id"
    t.date    "from_date"
    t.text    "to_date"
    t.float   "amount"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.string "description"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "number"
    t.datetime "date"
    t.string   "carrier"
    t.datetime "ship_date"
  end

  create_table "shipping_calculators", force: :cascade do |t|
    t.string "name"
    t.text   "description"
    t.string "calculation_method"
    t.string "calculation_amount"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.integer "shipping_calculator_id"
    t.string  "name"
    t.float   "rate"
    t.text    "description"
    t.boolean "active"
    t.float   "minimum_amount"
    t.float   "free_at_amount"
  end

  create_table "tracking_numbers", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "carrier_id"
    t.string  "number"
    t.boolean "delivered"
    t.string  "signed_by"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.integer  "group_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "number"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
