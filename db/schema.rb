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

ActiveRecord::Schema[8.1].define(version: 2026_08_18_161524) do
  create_table "challenges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "days", null: false
    t.string "name", null: false
    t.date "starts_on", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["token"], name: "index_challenges_on_token", unique: true
    t.index ["user_id"], name: "index_challenges_on_user_id"
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["user_id"], name: "index_magic_links_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.integer "challenge_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "person_token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["challenge_id", "person_token"], name: "index_participants_on_challenge_id_and_person_token", unique: true
    t.index ["challenge_id"], name: "index_participants_on_challenge_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "challenges", "users"
  add_foreign_key "magic_links", "users"
  add_foreign_key "participants", "challenges"
  add_foreign_key "participants", "users"
end
