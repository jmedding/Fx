# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100824112913) do

  create_table "accounts", :force => true do |t|
    t.integer  "currency_id"
    t.integer  "rules_id"
    t.integer  "type_id"
    t.float    "payment",     :default => 0.0
    t.integer  "period",      :default => 1
    t.string   "ccnum"
    t.date     "cc_exp"
    t.string   "cc_name"
    t.string   "paypal"
    t.integer  "address_id"
    t.integer  "external_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calculators", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "duration"
    t.string   "session_id"
    t.integer  "source_id"
    t.float    "provision"
    t.integer  "conversion_id"
    t.integer  "invert"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversions", :force => true do |t|
    t.integer  "currency_in"
    t.integer  "currency_out"
    t.date     "first"
    t.date     "last"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", :force => true do |t|
    t.string   "symbol"
    t.boolean  "base",        :default => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data", :force => true do |t|
    t.integer  "conversion_id"
    t.float    "rate"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exposures", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "conversion_id"
    t.boolean  "invert",        :default => false
    t.integer  "currency_in"
    t.integer  "currency_out"
    t.float    "carried_rate"
    t.float    "current_rate"
    t.integer  "amount"
    t.boolean  "supply",        :default => true
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "levels", :force => true do |t|
    t.string   "name"
    t.integer  "step"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "priviledges", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.float    "chance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", :force => true do |t|
    t.integer  "exposure_id"
    t.float    "factor"
    t.string   "description"
    t.float    "carried"
    t.date     "day"
    t.float    "recommended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tenders", :force => true do |t|
    t.integer  "project_id"
    t.integer  "group_id"
    t.date     "bid_date"
    t.date     "validity"
    t.integer  "user_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sessions", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login",              :default => "", :null => false
    t.string   "crypted_password",   :default => "", :null => false
    t.string   "password_salt",      :default => "", :null => false
    t.string   "persistence_token",  :default => "", :null => false
    t.string   "email",              :default => "", :null => false
    t.integer  "rating"
    t.integer  "group_id"
    t.integer  "account_id"
    t.integer  "login_count",        :default => 0,  :null => false
    t.integer  "failed_login_count", :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
