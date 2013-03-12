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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130312133327) do

  create_table "cloudstrg_cloudstrgplugins", :force => true do |t|
    t.string   "plugin_name"
    t.string   "version"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "cloudstrg_configs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cloudstrgplugin_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "cloudstrg_remoteobjects", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cloudstrgplugin_id"
    t.string   "filename"
    t.string   "filehash"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "file_remote_id"
  end

  create_table "collision_domains", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "workspace_id"
  end

  create_table "gdrivestrg_params", :force => true do |t|
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.date     "issued_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "user_id"
  end

  create_table "interfaces", :force => true do |t|
    t.integer  "virtual_machine_id"
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "collision_domain_id"
  end

  create_table "netlabsessions", :force => true do |t|
    t.integer  "user_id"
    t.string   "session_id"
    t.text     "params"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "scenes", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "schema"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "remote_id"
  end

  create_table "shellinaboxes", :force => true do |t|
    t.integer  "pid"
    t.integer  "user_id"
    t.integer  "virtual_machine_id"
    t.string   "host_name"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "port_number",        :default => -1
  end

  create_table "users", :force => true do |t|
    t.string   "email",               :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "encrypted_password"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "users_workspaces", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "workspace_id"
  end

  add_index "users_workspaces", ["user_id", "workspace_id"], :name => "index_users_workspaces_on_user_id_and_workspace_id"
  add_index "users_workspaces", ["workspace_id", "user_id"], :name => "index_users_workspaces_on_workspace_id_and_user_id"

  create_table "virtual_machines", :force => true do |t|
    t.integer  "workspace_id"
    t.string   "name"
    t.string   "node_type"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "state",        :default => "halted"
    t.integer  "port_number",  :default => -1
  end

  create_table "workspace_invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "workspace_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "workspaces", :force => true do |t|
    t.integer  "user_id"
    t.integer  "scene_id"
    t.string   "proxy"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
  end

end
