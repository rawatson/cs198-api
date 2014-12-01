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

ActiveRecord::Schema.define(version: 20141201090945) do

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

  create_table "enrollments", force: true do |t|
    t.integer "person_id"
    t.integer "course_id"
    t.string  "position"
    t.integer "seniority"
  end

  add_index "enrollments", ["person_id", "course_id"], name: "index_enrollments_on_person_id_and_course_id", using: :btree

  create_table "help_requests", force: true do |t|
    t.integer  "enrollment_id"
    t.text     "description"
    t.string   "location"
    t.boolean  "open",          default: true
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "helper_assignments", force: true do |t|
    t.integer  "helper_checkin_id"
    t.integer  "help_request_id"
    t.datetime "claim_time",        null: false
    t.datetime "close_time"
    t.string   "close_status"
    t.integer  "reassignment_id"
    t.text     "student_feedback"
    t.text     "helper_feedback"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "helper_checkins", force: true do |t|
    t.integer  "person_id"
    t.boolean  "checked_out",    default: false, null: false
    t.datetime "check_out_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "helper_checkins", ["checked_out"], name: "index_helper_checkins_on_checked_out", using: :btree

  create_table "lair_states", force: true do |t|
    t.boolean  "signups_enabled", default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
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

  create_table "terms", force: true do |t|
    t.string   "year",       null: false
    t.string   "title",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
