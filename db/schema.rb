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

ActiveRecord::Schema.define(:version => 20100526100729) do

  create_table "currencies", :force => true do |t|
    t.string   "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exposures", :force => true do |t|
    t.integer  "tender_id"
    t.integer  "currency_in"
    t.integer  "currency_out"
    t.float    "carried_rate"
    t.float    "current_rate"
    t.integer  "amount"
    t.boolean  "supply"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.integer  "rating"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
