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

ActiveRecord::Schema[7.1].define(version: 2025_12_06_180402) do
  create_table "contacts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "contact_user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_user_id"], name: "index_contacts_on_contact_user_id"
    t.index ["user_id", "contact_user_id"], name: "index_contacts_on_user_id_and_contact_user_id", unique: true
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "discussion_messages", force: :cascade do |t|
    t.integer "discussion_id", null: false
    t.integer "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id"], name: "index_discussion_messages_on_discussion_id"
    t.index ["user_id"], name: "index_discussion_messages_on_user_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "thread_type", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "thread_type"], name: "index_discussions_on_event_id_and_thread_type", unique: true
    t.index ["event_id"], name: "index_discussions_on_event_id"
  end

  create_table "event_attendees", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "user_id"], name: "index_event_attendees_on_event_id_and_user_id", unique: true
    t.index ["event_id"], name: "index_event_attendees_on_event_id"
    t.index ["user_id"], name: "index_event_attendees_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id", null: false
  end

  create_table "gift_ideas", force: :cascade do |t|
    t.integer "recipient_id", null: false
    t.integer "user_id", null: false
    t.text "idea", null: false
    t.decimal "estimated_price"
    t.boolean "favorited", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link"
    t.string "note", limit: 255
    t.string "status", default: "idea"
    t.index ["recipient_id"], name: "index_gift_ideas_on_recipient_id"
    t.index ["status"], name: "index_gift_ideas_on_status"
    t.index ["user_id"], name: "index_gift_ideas_on_user_id"
  end

  create_table "gifts_for_recipients", force: :cascade do |t|
    t.integer "recipient_id", null: false
    t.integer "user_id", null: false
    t.text "idea", null: false
    t.decimal "price"
    t.date "gift_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "idea"
    t.index ["recipient_id"], name: "index_gifts_for_recipients_on_recipient_id"
    t.index ["status"], name: "index_gifts_for_recipients_on_status"
    t.index ["user_id"], name: "index_gifts_for_recipients_on_user_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "age"
    t.string "occupation"
    t.text "hobbies"
    t.text "likes"
    t.text "dislikes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_recipients_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.string "gender", null: false
    t.string "occupation", null: false
    t.text "hobbies"
    t.text "likes"
    t.text "dislikes"
    t.string "street", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.string "country", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wish_list_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "url"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_wish_list_items_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_wish_list_items_on_user_id"
  end

  add_foreign_key "discussion_messages", "discussions"
  add_foreign_key "discussion_messages", "users"
  add_foreign_key "discussions", "events"
  add_foreign_key "events", "users", column: "creator_id"
  add_foreign_key "gift_ideas", "recipients"
  add_foreign_key "gift_ideas", "users"
  add_foreign_key "gifts_for_recipients", "recipients"
  add_foreign_key "gifts_for_recipients", "users"
  add_foreign_key "recipients", "events"
  add_foreign_key "wish_list_items", "users"
end
