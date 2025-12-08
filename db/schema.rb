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

ActiveRecord::Schema[8.0].define(version: 2025_12_08_012954) do
  create_table "avaliacoes", force: :cascade do |t|
    t.integer "turma_id", null: false
    t.integer "modelo_id", null: false
    t.integer "professor_alvo_id"
    t.datetime "data_inicio"
    t.datetime "data_fim"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modelo_id"], name: "index_avaliacoes_on_modelo_id"
    t.index ["professor_alvo_id"], name: "index_avaliacoes_on_professor_alvo_id"
    t.index ["turma_id"], name: "index_avaliacoes_on_turma_id"
  end

  create_table "matricula_turmas", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "turma_id", null: false
    t.string "papel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turma_id"], name: "index_matricula_turmas_on_turma_id"
    t.index ["user_id"], name: "index_matricula_turmas_on_user_id"
  end

  create_table "modelos", force: :cascade do |t|
    t.string "titulo"
    t.boolean "ativo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "perguntas", force: :cascade do |t|
    t.text "enunciado"
    t.string "tipo"
    t.json "opcoes"
    t.integer "modelo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modelo_id"], name: "index_perguntas_on_modelo_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.string "codigo"
    t.string "nome"
    t.string "semestre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "login"
    t.string "matricula"
    t.string "nome"
    t.string "formacao"
    t.boolean "eh_admin", default: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
  end

  add_foreign_key "avaliacoes", "modelos"
  add_foreign_key "avaliacoes", "turmas"
  add_foreign_key "avaliacoes", "users", column: "professor_alvo_id"
  add_foreign_key "matricula_turmas", "turmas"
  add_foreign_key "matricula_turmas", "users"
  add_foreign_key "perguntas", "modelos"
  add_foreign_key "sessions", "users"
end
