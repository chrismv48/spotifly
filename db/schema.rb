# typed: strict
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_26_215110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "artists_tracks", force: :cascade do |t|
    t.string "artist_id", null: false
    t.string "track_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_artists_tracks_on_artist_id"
    t.index ["track_id"], name: "index_artists_tracks_on_track_id"
  end

  create_table "playlist_tracks", force: :cascade do |t|
    t.string "playlist_id", null: false
    t.string "track_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_playlist_tracks_on_playlist_id"
    t.index ["track_id"], name: "index_playlist_tracks_on_track_id"
  end

  create_table "playlists", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "plays", force: :cascade do |t|
    t.string "track_id", null: false
    t.string "playlist_id"
    t.integer "progress_ms", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_plays_on_playlist_id"
    t.index ["track_id"], name: "index_plays_on_track_id"
  end

  create_table "spotify_user_tokens", force: :cascade do |t|
    t.integer "user_id"
    t.string "access_token"
    t.string "refresh_token"
    t.string "oauth_code"
    t.datetime "expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "track_items", id: :string, force: :cascade do |t|
    t.string "name"
    t.integer "duration_ms"
    t.float "popularity"
    t.float "acousticness"
    t.float "danceability"
    t.float "energy"
    t.float "instrumentalness"
    t.float "liveness"
    t.float "loudness"
    t.float "speechiness"
    t.float "valence"
    t.float "tempo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
