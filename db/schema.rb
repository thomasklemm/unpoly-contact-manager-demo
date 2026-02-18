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

ActiveRecord::Schema[8.1].define(version: 2026_02_18_074029) do
  create_table "activities", force: :cascade do |t|
    t.text "body", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_activities_on_contact_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "contact_tags", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "tag_id"], name: "index_contact_tags_on_contact_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_contact_tags_on_tag_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "archived_at"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.boolean "starred", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_contacts_on_archived_at"
    t.index ["company_id"], name: "index_contacts_on_company_id"
    t.index ["starred"], name: "index_contacts_on_starred"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end
end
