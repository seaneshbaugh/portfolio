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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110620041717) do

  create_table "sessions", :force => true do |t|
    t.integer  "user_id"
    t.string   "ip_address"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "salt"
    t.string   "encrypted_password"
    t.string   "cookie_code"
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "ip_addresses"
    t.integer  "privilege_level"
    t.integer  "login_count"
    t.integer  "post_count"
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
