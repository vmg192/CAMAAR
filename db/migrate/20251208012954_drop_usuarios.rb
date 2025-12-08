class DropUsuarios < ActiveRecord::Migration[8.0]
  def change
    drop_table :usuarios do |t|
      t.string "login"
      t.string "matricula"
      t.string "nome"
      t.string "email"
      t.string "formacao"
      t.string "password_digest"
      t.boolean "eh_admin", default: false
      t.timestamps
    end
  end
end