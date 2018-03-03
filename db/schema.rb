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

ActiveRecord::Schema.define(version: 20180303045131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pages", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.string "slug", default: "", null: false
    t.text "body", default: "", null: false
    t.text "style", default: "", null: false
    t.text "script", default: "", null: false
    t.text "meta_description", default: "", null: false
    t.text "meta_keywords", default: "", null: false
    t.integer "order", default: 0, null: false
    t.string "color", default: "", null: false
    t.boolean "show_in_menu", default: true, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["title"], name: "index_pages_on_title", unique: true
  end

  create_table "pictures", force: :cascade do |t|
    t.text "title", default: "", null: false
    t.text "alt_text", default: "", null: false
    t.text "caption", default: "", null: false
    t.string "image_file_name", null: false
    t.string "image_content_type", null: false
    t.integer "image_file_size", null: false
    t.string "image_fingerprint", null: false
    t.integer "image_original_width", null: false
    t.integer "image_original_height", null: false
    t.integer "image_medium_width", null: false
    t.integer "image_medium_height", null: false
    t.integer "image_thumb_width", null: false
    t.integer "image_thumb_height", null: false
    t.datetime "image_updated_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["image_content_type"], name: "index_pictures_on_image_content_type"
    t.index ["image_file_name"], name: "index_pictures_on_image_file_name"
    t.index ["image_fingerprint"], name: "index_pictures_on_image_fingerprint"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", default: "", null: false
    t.string "slug", default: "", null: false
    t.text "body", default: "", null: false
    t.text "style", default: "", null: false
    t.text "script", default: "", null: false
    t.text "meta_description", default: "", null: false
    t.text "meta_keywords", default: "", null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["title"], name: "index_posts_on_title", unique: true
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "role", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
