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

ActiveRecord::Schema[8.1].define(version: 2026_05_26_030738) do
  create_table "jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "job_url", null: false
    t.string "location"
    t.datetime "posted_at"
    t.string "salary"
    t.string "source", default: "vietnamworks", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["company_name"], name: "index_jobs_on_company_name"
    t.index ["job_url"], name: "index_jobs_on_job_url", unique: true
    t.index ["location"], name: "index_jobs_on_location"
  end
end
