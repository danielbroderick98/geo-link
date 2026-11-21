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

ActiveRecord::Schema[8.1].define(version: 2026_10_26_092304) do
  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "region", null: false
    t.string "capital", null: false
    t.integer "population", null: false
    t.string "political_system", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "LOWER(name)", name: "index_countries_on_lower_name", unique: true
    t.check_constraint "population >= 0", name: "countries_population_non_negative"
  end

  create_table "diplomatic_relationships", force: :cascade do |t|
    t.integer "country_1_id", null: false
    t.integer "country_2_id", null: false
    t.string "relationship_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_1_id"], name: "index_diplomatic_relationships_on_country_1_id"
    t.index ["country_2_id"], name: "index_diplomatic_relationships_on_country_2_id"
  end

  create_table "event_countries", force: :cascade do |t|
    t.integer "geopolitical_event_id", null: false
    t.integer "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_event_countries_on_country_id"
    t.index ["geopolitical_event_id", "country_id"], name: "index_event_countries_on_geopolitical_event_id_and_country_id", unique: true
    t.index ["geopolitical_event_id"], name: "index_event_countries_on_geopolitical_event_id"
  end

  create_table "geopolitical_events", force: :cascade do |t|
    t.string "title"
    t.string "event_type"
    t.date "started_on"
    t.date "ended_on"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "treaties", force: :cascade do |t|
    t.string "name"
    t.date "date_signed"
    t.string "status"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "treaty_participants", force: :cascade do |t|
    t.integer "treaty_id", null: false
    t.integer "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_treaty_participants_on_country_id"
    t.index ["treaty_id"], name: "index_treaty_participants_on_treaty_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role", default: "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "diplomatic_relationships", "countries", column: "country_1_id"
  add_foreign_key "diplomatic_relationships", "countries", column: "country_2_id"
  add_foreign_key "event_countries", "countries"
  add_foreign_key "event_countries", "geopolitical_events"
  add_foreign_key "treaty_participants", "countries"
  add_foreign_key "treaty_participants", "treaties"
end
