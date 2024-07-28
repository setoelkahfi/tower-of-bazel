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

ActiveRecord::Schema.define(version: 2024_02_05_114851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "album_artists", force: :cascade do |t|
    t.boolean "primary"
    t.bigint "album_id"
    t.bigint "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_album_artists_on_album_id"
    t.index ["artist_id"], name: "index_album_artists_on_artist_id"
  end

  create_table "album_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "album_id"
    t.string "provider_id"
    t.integer "provider_type"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_id"], name: "index_album_providers_on_album_id"
    t.index ["user_id"], name: "index_album_providers_on_user_id"
  end

  create_table "album_votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "album_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_id"], name: "index_album_votes_on_album_id"
    t.index ["user_id"], name: "index_album_votes_on_user_id"
  end

  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.bigint "user_id"
    t.index ["user_id"], name: "index_albums_on_user_id"
  end

  create_table "artist_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider_id"
    t.integer "provider_type"
    t.string "name"
    t.string "genres"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "artist_id"
    t.index ["artist_id"], name: "index_artist_providers_on_artist_id"
    t.index ["user_id"], name: "index_artist_providers_on_user_id"
  end

  create_table "artist_votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "artist_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["artist_id"], name: "index_artist_votes_on_artist_id"
    t.index ["user_id"], name: "index_artist_votes_on_user_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.bigint "user_id"
    t.index ["user_id"], name: "index_artists_on_user_id"
  end

  create_table "audio_file_bass64_statuses", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processing_progress", default: 0
    t.index ["audio_file_id"], name: "index_audio_file_bass64_statuses_on_audio_file_id"
  end

  create_table "audio_file_bonzo_statuses", force: :cascade do |t|
    t.integer "status"
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processing_progress", default: 0
    t.index ["audio_file_id"], name: "index_audio_file_bonzo_statuses_on_audio_file_id"
  end

  create_table "audio_file_karokowe_statuses", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processing_progress", default: 0
    t.index ["audio_file_id"], name: "index_audio_file_karokowe_statuses_on_audio_file_id"
  end

  create_table "audio_file_split_statuses", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.integer "status"
    t.integer "processing_progress", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_audio_file_split_statuses_on_audio_file_id"
  end

  create_table "audio_files", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "song_provider_id"
    t.integer "status", default: 0
    t.integer "progress", default: 0
    t.index ["song_provider_id"], name: "index_audio_files_on_song_provider_id"
  end

  create_table "authorizations", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "onboarding_status", default: 0
    t.boolean "onboarding_status_progress", default: false
    t.string "refresh_token"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "badges_sashes", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "sash_id"
    t.boolean "notified_user", default: false
    t.datetime "created_at"
    t.index ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id"
    t.index ["badge_id"], name: "index_badges_sashes_on_badge_id"
    t.index ["sash_id"], name: "index_badges_sashes_on_sash_id"
  end

  create_table "bass_backing_track_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.integer "status", default: 0
    t.integer "status_progress", default: 0
    t.integer "views_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_bass_backing_track_files_on_audio_file_id"
  end

  create_table "bass_backing_tracks", force: :cascade do |t|
    t.boolean "is_public"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "audio_file_id"
    t.index ["audio_file_id"], name: "index_bass_backing_tracks_on_audio_file_id"
  end

  create_table "bass_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_bass_files_on_audio_file_id"
  end

  create_table "chord_histories", force: :cascade do |t|
    t.bigint "chord_id"
    t.bigint "user_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chord_id"], name: "index_chord_histories_on_chord_id"
    t.index ["user_id"], name: "index_chord_histories_on_user_id"
  end

  create_table "chord_shapes", force: :cascade do |t|
    t.string "name"
    t.string "youtube_link"
    t.string "image_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chord_votes", force: :cascade do |t|
    t.bigint "chord_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chord_id"], name: "index_chord_votes_on_chord_id"
    t.index ["user_id"], name: "index_chord_votes_on_user_id"
  end

  create_table "chords", force: :cascade do |t|
    t.text "chord"
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "title"
    t.integer "status", default: 0
    t.bigint "song_provider_id"
    t.index ["song_provider_id"], name: "index_chords_on_song_provider_id"
    t.index ["user_id"], name: "index_chords_on_user_id"
  end

  create_table "chords_song_providers", id: false, force: :cascade do |t|
    t.bigint "chord_id", null: false
    t.bigint "song_provider_id", null: false
    t.index ["chord_id"], name: "index_chords_song_providers_on_chord_id"
    t.index ["song_provider_id"], name: "index_chords_song_providers_on_song_provider_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "drum_backing_tracks", force: :cascade do |t|
    t.boolean "is_public"
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.integer "status_progress", default: 0
    t.integer "views_count", default: 0
    t.index ["audio_file_id"], name: "index_drum_backing_tracks_on_audio_file_id"
  end

  create_table "drum_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_drum_files_on_audio_file_id"
  end

  create_table "gending_notation_votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "javanese_gending_notation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["javanese_gending_notation_id"], name: "index_gending_notation_votes_on_javanese_gending_notation_id"
    t.index ["user_id"], name: "index_gending_notation_votes_on_user_id"
  end

  create_table "gending_votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "javanese_gending_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["javanese_gending_id"], name: "index_gending_votes_on_javanese_gending_id"
    t.index ["user_id"], name: "index_gending_votes_on_user_id"
  end

  create_table "guitar_backing_track_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.integer "status", default: 0
    t.integer "status_progress", default: 0
    t.integer "views_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_guitar_backing_track_files_on_audio_file_id"
  end

  create_table "javanese_gending_notations", force: :cascade do |t|
    t.string "name"
    t.text "notation"
    t.integer "views_count"
    t.boolean "is_published"
    t.bigint "user_id"
    t.bigint "javanese_gending_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "rich_format"
    t.index ["javanese_gending_id"], name: "index_javanese_gending_notations_on_javanese_gending_id"
    t.index ["user_id"], name: "index_javanese_gending_notations_on_user_id"
  end

  create_table "javanese_gendings", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "notation"
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_javanese_gendings_on_user_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "karaoke_file_lovers", force: :cascade do |t|
    t.bigint "karaoke_file_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "clicks_count"
    t.index ["karaoke_file_id"], name: "index_karaoke_file_lovers_on_karaoke_file_id"
    t.index ["user_id"], name: "index_karaoke_file_lovers_on_user_id"
  end

  create_table "karaoke_files", force: :cascade do |t|
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "clicks_count", default: 0
    t.bigint "audio_file_id"
    t.boolean "is_public", default: false
    t.index ["audio_file_id"], name: "index_karaoke_files_on_audio_file_id"
  end

  create_table "lyric_synches", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.bigint "user_id"
    t.string "lyric"
    t.string "time"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["audio_file_id"], name: "index_lyric_synches_on_audio_file_id"
    t.index ["user_id"], name: "index_lyric_synches_on_user_id"
  end

  create_table "lyric_votes", force: :cascade do |t|
    t.bigint "lyric_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lyric_id"], name: "index_lyric_votes_on_lyric_id"
    t.index ["user_id"], name: "index_lyric_votes_on_user_id"
  end

  create_table "lyrics", force: :cascade do |t|
    t.text "lyric"
    t.string "locale"
    t.bigint "song_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.bigint "user_id"
    t.boolean "is_published", default: false
    t.index ["user_id"], name: "index_lyrics_on_user_id"
  end

  create_table "merit_actions", force: :cascade do |t|
    t.integer "user_id"
    t.string "action_method"
    t.integer "action_value"
    t.boolean "had_errors", default: false
    t.string "target_model"
    t.integer "target_id"
    t.text "target_data"
    t.boolean "processed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["processed"], name: "index_merit_actions_on_processed"
  end

  create_table "merit_activity_logs", force: :cascade do |t|
    t.integer "action_id"
    t.string "related_change_type"
    t.integer "related_change_id"
    t.string "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: :cascade do |t|
    t.bigint "score_id"
    t.bigint "num_points", default: 0
    t.string "log"
    t.datetime "created_at"
    t.index ["score_id"], name: "index_merit_score_points_on_score_id"
  end

  create_table "merit_scores", force: :cascade do |t|
    t.bigint "sash_id"
    t.string "category", default: "default"
    t.index ["sash_id"], name: "index_merit_scores_on_sash_id"
  end

  create_table "meta", id: :bigint, default: -> { "nextval('meta_pages_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "home"
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "locale"
  end

  create_table "meta_pages", id: :serial, force: :cascade do |t|
  end

  create_table "other_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_other_files_on_audio_file_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "page_slug"
    t.text "page_content"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "category"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "sashes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "search_terms", force: :cascade do |t|
    t.string "term"
    t.integer "count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "song_artists", force: :cascade do |t|
    t.boolean "primary"
    t.bigint "song_id"
    t.bigint "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "song_provider_id"
    t.bigint "artist_provider_id"
    t.index ["artist_id"], name: "index_song_artists_on_artist_id"
    t.index ["artist_provider_id"], name: "index_song_artists_on_artist_provider_id"
    t.index ["song_id"], name: "index_song_artists_on_song_id"
    t.index ["song_provider_id"], name: "index_song_artists_on_song_provider_id"
  end

  create_table "song_chord_pleas", force: :cascade do |t|
    t.bigint "song_id"
    t.bigint "user_id"
    t.index ["song_id"], name: "index_song_chord_pleas_on_song_id"
    t.index ["user_id"], name: "index_song_chord_pleas_on_user_id"
  end

  create_table "song_provider_chords", force: :cascade do |t|
    t.bigint "song_provider_id"
    t.bigint "chord_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chord_id"], name: "index_song_provider_chords_on_chord_id"
    t.index ["song_provider_id"], name: "index_song_provider_chords_on_song_provider_id"
  end

  create_table "song_provider_votes", force: :cascade do |t|
    t.bigint "song_provider_id"
    t.bigint "user_id"
    t.integer "vote_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["song_provider_id"], name: "index_song_provider_votes_on_song_provider_id"
    t.index ["user_id"], name: "index_song_provider_votes_on_user_id"
  end

  create_table "song_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "song_id"
    t.string "provider_id"
    t.integer "provider_type"
    t.string "name"
    t.string "preview_url"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "description"
    t.string "image_url"
    t.integer "status", default: 0
    t.index ["provider_id", "provider_type"], name: "index_song_providers_on_provider_id_and_provider_type", unique: true
    t.index ["song_id"], name: "index_song_providers_on_song_id"
    t.index ["user_id"], name: "index_song_providers_on_user_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "album_id"
    t.integer "views_count", default: 0
    t.bigint "user_id"
    t.index ["album_id"], name: "index_songs_on_album_id"
    t.index ["user_id"], name: "index_songs_on_user_id"
  end

  create_table "splitfire_results", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "length"
    t.json "onset"
    t.index ["audio_file_id"], name: "index_splitfire_results_on_audio_file_id"
  end

  create_table "tolk_locales", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tolk_locales_on_name", unique: true
  end

  create_table "tolk_phrases", id: :serial, force: :cascade do |t|
    t.text "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tolk_translations", id: :serial, force: :cascade do |t|
    t.integer "phrase_id"
    t.integer "locale_id"
    t.text "text"
    t.text "previous_text"
    t.boolean "primary_updated", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["phrase_id", "locale_id"], name: "index_tolk_translations_on_phrase_id_and_locale_id", unique: true
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "model"
    t.integer "frequency"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "locale", default: 0
    t.integer "sync_spotify", default: 1
    t.integer "allowed_use_google_token", default: 0
    t.integer "allowed_use_spotify_token", default: 0
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.string "username"
    t.text "image"
    t.string "provider"
    t.string "uid"
    t.boolean "is_private", default: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin"
    t.string "instagram"
    t.string "youtube_channel_id"
    t.string "about"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "sash_id"
    t.integer "level", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vocal_files", force: :cascade do |t|
    t.bigint "audio_file_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audio_file_id"], name: "index_vocal_files_on_audio_file_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "pubkey"
    t.text "seed_phrase"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.string "bach_token_account"
    t.integer "wallet_type", default: 1
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "album_artists", "albums"
  add_foreign_key "album_artists", "artists"
  add_foreign_key "album_providers", "albums"
  add_foreign_key "album_providers", "users"
  add_foreign_key "album_votes", "albums"
  add_foreign_key "album_votes", "users"
  add_foreign_key "albums", "users"
  add_foreign_key "artist_providers", "artists"
  add_foreign_key "artist_providers", "users"
  add_foreign_key "artist_votes", "artists"
  add_foreign_key "artist_votes", "users"
  add_foreign_key "artists", "users"
  add_foreign_key "audio_file_bass64_statuses", "audio_files"
  add_foreign_key "audio_file_bonzo_statuses", "audio_files"
  add_foreign_key "audio_file_karokowe_statuses", "audio_files"
  add_foreign_key "audio_file_split_statuses", "audio_files"
  add_foreign_key "authorizations", "users"
  add_foreign_key "bass_backing_track_files", "audio_files"
  add_foreign_key "bass_backing_tracks", "audio_files"
  add_foreign_key "bass_files", "audio_files"
  add_foreign_key "chord_histories", "chords"
  add_foreign_key "chord_histories", "users"
  add_foreign_key "chord_votes", "chords"
  add_foreign_key "chord_votes", "users"
  add_foreign_key "chords", "song_providers"
  add_foreign_key "chords", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "drum_backing_tracks", "audio_files"
  add_foreign_key "drum_files", "audio_files"
  add_foreign_key "gending_notation_votes", "javanese_gending_notations"
  add_foreign_key "gending_notation_votes", "users"
  add_foreign_key "gending_votes", "javanese_gendings"
  add_foreign_key "gending_votes", "users"
  add_foreign_key "guitar_backing_track_files", "audio_files"
  add_foreign_key "javanese_gending_notations", "javanese_gendings"
  add_foreign_key "javanese_gending_notations", "users"
  add_foreign_key "javanese_gendings", "users"
  add_foreign_key "karaoke_file_lovers", "karaoke_files"
  add_foreign_key "karaoke_file_lovers", "users"
  add_foreign_key "karaoke_files", "audio_files"
  add_foreign_key "lyric_synches", "audio_files"
  add_foreign_key "lyric_synches", "users"
  add_foreign_key "lyric_votes", "lyrics"
  add_foreign_key "lyric_votes", "users"
  add_foreign_key "lyrics", "songs"
  add_foreign_key "lyrics", "users"
  add_foreign_key "other_files", "audio_files"
  add_foreign_key "song_artists", "artist_providers"
  add_foreign_key "song_artists", "artists"
  add_foreign_key "song_artists", "song_providers"
  add_foreign_key "song_artists", "songs"
  add_foreign_key "song_chord_pleas", "songs"
  add_foreign_key "song_chord_pleas", "users"
  add_foreign_key "song_provider_chords", "chords"
  add_foreign_key "song_provider_chords", "song_providers"
  add_foreign_key "song_provider_votes", "song_providers"
  add_foreign_key "song_provider_votes", "users"
  add_foreign_key "song_providers", "songs"
  add_foreign_key "song_providers", "users"
  add_foreign_key "songs", "albums"
  add_foreign_key "songs", "users"
  add_foreign_key "splitfire_results", "audio_files"
  add_foreign_key "user_settings", "users"
  add_foreign_key "vocal_files", "audio_files"
  add_foreign_key "wallets", "users"
end
