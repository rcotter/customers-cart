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

ActiveRecord::Schema.define(version: 20160430033419) do

  create_table "customers", force: :cascade do |t|
    t.string   "customer_id",                       null: false
    t.string   "first_name",                        null: false
    t.string   "last_name",                         null: false
    t.date     "date_of_birth",                     null: false
    t.integer  "first_purchase_at"
    t.boolean  "approved",          default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "customers", ["customer_id"], name: "customers_on_customer_id", unique: true

  create_table "items", force: :cascade do |t|
    t.string   "item_id",      null: false
    t.string   "customer_id",  null: false
    t.integer  "amount_cents", null: false
    t.string   "name",         null: false
    t.string   "status",       null: false
    t.integer  "purchased_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "items", ["customer_id", "status", "purchased_at"], name: "items_on_customer_id_status_purchased_at", unique: true

end
