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

ActiveRecord::Schema.define(version: 20141027175320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: true do |t|
    t.string   "code"
    t.string   "title"
    t.string   "website"
    t.string   "registry_doc_name"
    t.integer  "term_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "people", force: true do |t|
    t.string   "suid"
    t.string   "sunet_id",       null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nick_name"
    t.string   "email",          null: false
    t.string   "phone_number"
    t.boolean  "gender"
    t.boolean  "scpd"
    t.boolean  "staff",          null: false
    t.boolean  "active"
    t.string   "citizen_status"
    t.datetime "hire_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "people", ["suid"], name: "index_people_on_suid", unique: true, using: :btree
  add_index "people", ["sunet_id"], name: "index_people_on_sunet_id", unique: true, using: :btree

  create_table "positions", force: true do |t|
    t.string  "title"
    t.integer "seniority"
  end

  create_table "terms", force: true do |t|
    t.string   "year",       null: false
    t.string   "title",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
