class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :login
      t.string :matricula
      t.string :nome
      t.string :email
      t.string :formacao
      t.string :password_digest
      t.boolean :eh_admin, default: false

      t.timestamps
    end

    add_index :usuarios, :login, unique: true
    add_index :usuarios, :matricula, unique: true
    add_index :usuarios, :email, unique: true
  end
end
