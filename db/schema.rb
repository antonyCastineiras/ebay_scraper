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

ActiveRecord::Schema.define(version: 20170830111313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ebay_scrapes", force: :cascade do |t|
    t.string   "search"
    t.text     "object"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "max_number_of_results",    default: 50
    t.float    "average_price_of_results"
    t.float    "average_deviation_of_result_price"
  end

  create_table "results", force: :cascade do |t|
    t.text     "object"
    t.integer  "ebay_scrape_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "title"
    t.float    "price"
    t.string   "href"
    t.string   "format"
    t.float    "shipping"
    t.string   "condition"
    t.text     "page"
    t.float    "average_price_of_search"
    t.index ["ebay_scrape_id"], name: "index_results_on_ebay_scrape_id", using: :btree
  end

  add_foreign_key "results", "ebay_scrapes"
end
