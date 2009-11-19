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

ActiveRecord::Schema.define(:version => 20091119111302) do

  create_table "companies", :force => true do |t|
    t.string   "name",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",      :default => "#68a1e5", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                               :null => false
    t.string   "alias",                               :null => false
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.boolean  "admin",                               :null => false
    t.string   "name"
    t.string   "email"
    t.boolean  "active_employee",   :default => true, :null => false
  end

  create_table "work_periods", :force => true do |t|
    t.datetime "start",           :null => false
    t.datetime "end",             :null => false
    t.integer  "user_id",         :null => false
    t.integer  "worklog_task_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
  end

  add_index "work_periods", ["user_id", "start", "end"], :name => "index_work_periods_on_user_id_and_start_and_end", :unique => true

  create_table "worklog_tasks", :force => true do |t|
    t.string   "name",                                         :null => false
    t.integer  "company_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",                 :default => "#68a1e5", :null => false
    t.boolean  "visible_in_user_menus", :default => true,      :null => false
  end

end
