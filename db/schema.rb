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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20170928125123) do

  create_table "alternatives", :force => true do |t|
    t.text     "text"
    t.integer  "question_id"
    t.boolean  "correct",     :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "asset_reports", :force => true do |t|
    t.boolean  "done",          :default => false
    t.integer  "subject_id"
    t.integer  "lecture_id"
    t.integer  "enrollment_id"
    t.datetime "updated_at"
  end

  add_index "asset_reports", ["enrollment_id", "lecture_id"], :name => "index_asset_reports_on_enrollment_id_and_lecture_id", :unique => true
  add_index "asset_reports", ["enrollment_id"], :name => "index_asset_reports_on_enrollment_id"
  add_index "asset_reports", ["lecture_id"], :name => "index_asset_reports_on_lecture_id"

  create_table "audiences", :force => true do |t|
    t.string "name"
  end

  create_table "audiences_courses", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "course_id"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "canvas", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_application_id"
    t.integer  "container_id"
    t.string   "container_type"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "url"
    t.string   "name"
  end

  create_table "chat_message_associations", :force => true do |t|
    t.integer  "chat_id"
    t.integer  "chat_message_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "chat_message_associations", ["chat_id"], :name => "index_chat_message_associations_on_chat_id"
  add_index "chat_message_associations", ["chat_message_id"], :name => "index_chat_message_associations_on_chat_message_id"

  create_table "chat_messages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "body"
    t.integer  "conversation_id"
  end

  add_index "chat_messages", ["contact_id"], :name => "index_chat_messages_on_contact_id"
  add_index "chat_messages", ["conversation_id"], :name => "index_chat_messages_on_conversation_id"
  add_index "chat_messages", ["user_id"], :name => "index_chat_messages_on_user_id"

  create_table "chats", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "chats", ["contact_id"], :name => "index_chats_on_contact_id"
  add_index "chats", ["user_id"], :name => "index_chats_on_user_id"

  create_table "choices", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "correct",        :default => false
    t.integer  "alternative_id"
    t.integer  "result_id"
    t.integer  "question_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "choices", ["user_id", "question_id"], :name => "index_choices_on_user_id_and_question_id", :unique => true

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 40
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "walledgarden",               :default => false
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true
  add_index "client_applications", ["walledgarden", "id"], :name => "index_client_applications_on_walledgarden_and_id"

  create_table "complementary_courses", :force => true do |t|
    t.string   "course"
    t.string   "institution"
    t.date     "year"
    t.integer  "workload"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "conversations", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "conversations", ["recipient_id"], :name => "index_conversations_on_recipient_id"
  add_index "conversations", ["sender_id"], :name => "index_conversations_on_sender_id"

  create_table "course_enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.string   "state"
    t.string   "token"
    t.string   "email"
    t.string   "role"
    t.string   "type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "last_accessed_at"
  end

  add_index "course_enrollments", ["course_id", "user_id"], :name => "index_course_enrollments_on_course_id_and_user_id"
  add_index "course_enrollments", ["role", "state"], :name => "index_user_course_associations_on_role_and_state"
  add_index "course_enrollments", ["role"], :name => "index_user_course_associations_on_role"
  add_index "course_enrollments", ["state", "course_id"], :name => "index_user_course_associations_on_course_and_state"
  add_index "course_enrollments", ["state"], :name => "index_user_course_associations_on_state"
  add_index "course_enrollments", ["token"], :name => "index_user_course_associations_on_token"
  add_index "course_enrollments", ["user_id", "course_id", "type"], :name => "idx_course_enrollments_uid_cid_type", :unique => true
  add_index "course_enrollments", ["user_id", "course_id"], :name => "index_course_enrollments_on_user_id_and_course_id"
  add_index "course_enrollments", ["user_id"], :name => "index_course_enrollments_on_user_id"

  create_table "course_resources", :force => true do |t|
    t.string   "name"
    t.string   "attachment_file_name"
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "path"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "environment_id"
    t.integer  "workload"
    t.integer  "subscription_type", :default => 1
    t.integer  "user_id"
    t.boolean  "published",         :default => true
    t.boolean  "destroy_soon",      :default => false
    t.boolean  "blocked",           :default => false
  end

  add_index "courses", ["destroy_soon"], :name => "index_courses_on_destroy_soon"
  add_index "courses", ["environment_id"], :name => "index_courses_on_environment_id"
  add_index "courses", ["user_id"], :name => "index_courses_on_user_id"

  create_table "documents", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "state"
    t.boolean  "published",               :default => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "livredoc_id"
  end

  create_table "educations", :force => true do |t|
    t.string   "educationable_type"
    t.integer  "educationable_id"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "role"
    t.boolean  "graduated",  :default => false
    t.float    "grade",      :default => 0.0
  end

  add_index "enrollments", ["graduated"], :name => "index_enrollments_on_graduaded"
  add_index "enrollments", ["role"], :name => "index_enrollments_on_role"
  add_index "enrollments", ["subject_id"], :name => "index_enrollments_on_subject_id"
  add_index "enrollments", ["user_id", "subject_id"], :name => "idx_enrollments_u_id_and_sid", :unique => true
  add_index "enrollments", ["user_id", "subject_id"], :name => "index_enrollments_on_user_id_and_subject_id", :unique => true
  add_index "enrollments", ["user_id"], :name => "index_enrollments_on_user_id"

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "path"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "user_id",                                              :null => false
    t.boolean  "published",                         :default => true
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "initials",            :limit => 80,                    :null => false
    t.boolean  "destroy_soon",                      :default => false
    t.boolean  "blocked",                           :default => false
  end

  add_index "environments", ["destroy_soon"], :name => "index_environments_on_destroy_soon"
  add_index "environments", ["user_id"], :name => "index_environments_on_user_id"

  create_table "event_educations", :force => true do |t|
    t.string   "name"
    t.string   "role"
    t.date     "year"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "exercises", :force => true do |t|
    t.decimal  "maximum_grade", :precision => 4, :scale => 2, :default => 10.0
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  create_table "experiences", :force => true do |t|
    t.string   "title"
    t.string   "company"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "current",     :default => false
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.datetime "date_modified"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "space_id"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "requested_at", :null => false
    t.datetime "accepted_at"
    t.string   "status"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["status"], :name => "index_friendships_on_status"
  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "high_schools", :force => true do |t|
    t.string   "institution"
    t.date     "end_year"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "higher_educations", :force => true do |t|
    t.string   "kind"
    t.string   "institution"
    t.date     "start_year"
    t.date     "end_year"
    t.text     "description"
    t.string   "course"
    t.string   "research_area"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.string   "token"
    t.string   "hostable_type"
    t.integer  "hostable_id"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "lectures", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_average",   :default => 0
    t.integer  "user_id",                             :null => false
    t.datetime "media_updated_at"
    t.integer  "view_count",       :default => 0
    t.string   "lectureable_type"
    t.integer  "lectureable_id"
    t.boolean  "is_clone",         :default => false
    t.integer  "subject_id"
    t.integer  "position"
    t.boolean  "blocked",          :default => false
  end

  add_index "lectures", ["lectureable_id", "lectureable_type"], :name => "lectures_lectureable_id_and_type"
  add_index "lectures", ["subject_id"], :name => "index_lectures_on_subject_id"
  add_index "lectures", ["user_id"], :name => "index_lectures_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "myfiles", :force => true do |t|
    t.integer  "folder_id"
    t.integer  "user_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 40
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "expires_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "pages", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "state"
    t.string   "name"
    t.integer  "video_storage_limit"
    t.integer  "members_limit"
    t.integer  "file_storage_limit"
    t.integer  "user_id"
    t.integer  "billable_id"
    t.string   "billable_type"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "billable_audit"
    t.string   "type"
    t.boolean  "current",             :default => false
  end

  add_index "plans", ["current"], :name => "index_plans_on_current"

  create_table "questions", :force => true do |t|
    t.integer  "exercise_id"
    t.text     "statement"
    t.text     "explanation"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "quotas", :force => true do |t|
    t.integer  "multimedia",    :default => 0
    t.integer  "files",         :default => 0
    t.integer  "billable_id"
    t.string   "billable_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "rates", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars",         :null => false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], :name => "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", ["rater_id"], :name => "index_rates_on_rater_id"

  create_table "results", :force => true do |t|
    t.integer  "user_id"
    t.integer  "exercise_id"
    t.datetime "started_at"
    t.datetime "finalized_at"
    t.string   "state"
    t.decimal  "grade",        :precision => 4, :scale => 2, :default => 0.0
    t.integer  "duration",                                   :default => 0
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  create_table "seminars", :force => true do |t|
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.time     "media_updated_at"
    t.string   "external_resource"
    t.string   "external_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",              :default => false
    t.string   "state"
    t.string   "original_file_name"
    t.string   "original_content_type"
    t.integer  "original_file_size"
    t.datetime "original_updated_at"
    t.integer  "job"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "social_networks", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "social_networks", ["user_id"], :name => "index_social_networks_on_user_id"

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                                :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "removed",             :default => false
    t.integer  "members_count",       :default => 0
    t.integer  "course_id"
    t.boolean  "published",           :default => true
    t.boolean  "destroy_soon",        :default => false
    t.boolean  "blocked",             :default => false
  end

  add_index "spaces", ["course_id"], :name => "index_spaces_on_course_id"
  add_index "spaces", ["destroy_soon"], :name => "index_spaces_on_destroy_soon"
  add_index "spaces", ["user_id"], :name => "index_spaces_on_user_id"

  create_table "status_resources", :force => true do |t|
    t.string   "provider"
    t.string   "thumb_url"
    t.string   "title"
    t.text     "description"
    t.string   "link"
    t.integer  "status_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "status_resources", ["status_id"], :name => "index_status_resources_on_status_id"

  create_table "status_user_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "status_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "status_user_associations", ["status_id"], :name => "sua_status_id"
  add_index "status_user_associations", ["user_id", "status_id"], :name => "index_status_user_associations_on_user_id_and_status_id", :unique => true
  add_index "status_user_associations", ["user_id"], :name => "index_status_user_associations_on_user_id"

  create_table "statuses", :force => true do |t|
    t.text     "text"
    t.integer  "in_response_to_id"
    t.string   "in_response_to_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "statusable_id",                          :null => false
    t.string   "statusable_type",                        :null => false
    t.string   "logeable_type"
    t.integer  "logeable_id"
    t.string   "action"
    t.string   "type"
    t.boolean  "compound",            :default => false
    t.integer  "compound_log_id"
    t.datetime "compound_visible_at"
  end

  add_index "statuses", ["compound"], :name => "index_statuses_compound"
  add_index "statuses", ["compound_log_id"], :name => "index_statuses_compound_log_id"
  add_index "statuses", ["compound_visible_at"], :name => "index_statuses_compound_visible_at"
  add_index "statuses", ["in_response_to_id", "in_response_to_type"], :name => "statuses_on_response_to_id_and_response_to_type_ix"
  add_index "statuses", ["logeable_id", "logeable_type"], :name => "index_statuses_on_logeable_id_and_logeable_type"
  add_index "statuses", ["statusable_type", "statusable_id"], :name => "index_statuses_on_statusable_type_and_statusable_id"

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "space_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "visible",     :default => true
    t.boolean  "finalized",   :default => false
    t.boolean  "blocked",     :default => false
  end

  add_index "subjects", ["space_id"], :name => "index_subjects_on_space_id"
  add_index "subjects", ["user_id"], :name => "index_subjects_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_environment_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "environment_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "role"
  end

  add_index "user_environment_associations", ["environment_id", "user_id"], :name => "uea_environment_id_user_id"
  add_index "user_environment_associations", ["environment_id"], :name => "uea_environment_id"
  add_index "user_environment_associations", ["user_id", "environment_id"], :name => "uea_user_id_environment_id", :unique => true
  add_index "user_environment_associations", ["user_id"], :name => "index_user_environment_associations_on_user_id"

  create_table "user_settings", :force => true do |t|
    t.integer "user_id"
    t.string  "view_mural"
    t.text    "explored"
  end

  add_index "user_settings", ["user_id"], :name => "index_user_settings_on_user_id"

  create_table "user_space_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "space_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_space_associations", ["space_id", "user_id"], :name => "usa_space_id_user_id"
  add_index "user_space_associations", ["space_id"], :name => "index_user_space_associations_on_space_id"
  add_index "user_space_associations", ["user_id", "space_id"], :name => "index_user_space_associations_on_user_id_and_space_id", :unique => true
  add_index "user_space_associations", ["user_id", "space_id"], :name => "usa_user_id_space_id"
  add_index "user_space_associations", ["user_id"], :name => "index_user_space_associations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.text     "description"
    t.integer  "avatar_id"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "activation_code",       :limit => 40
    t.datetime "activated_at"
    t.string   "login_slug"
    t.boolean  "notify_messages",                     :default => true
    t.boolean  "notify_followships",                  :default => true
    t.boolean  "notify_community_news",               :default => true
    t.datetime "last_login_at"
    t.string   "zip"
    t.date     "birthday"
    t.string   "gender"
    t.boolean  "profile_public",                      :default => true
    t.string   "role"
    t.integer  "score",                               :default => 0
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "my_activity",                         :default => true
    t.boolean  "removed",                             :default => false
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                         :default => 0
    t.integer  "failed_login_count",                  :default => 0
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "auto_status",                         :default => true
    t.boolean  "has_invited",                         :default => false
    t.integer  "friends_count",                       :default => 0,     :null => false
    t.string   "mobile"
    t.string   "localization"
    t.string   "birth_localization"
    t.string   "languages"
    t.text     "favorite_quotation"
    t.boolean  "destroy_soon"
    t.string   "recovery_token"
    t.string   "channel"
  end

  add_index "users", ["activated_at"], :name => "index_users_on_activated_at"
  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["destroy_soon"], :name => "index_users_on_destroy_soon"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["login_slug"], :name => "index_users_on_login_slug"
  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["role"], :name => "index_users_on_role"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

end
