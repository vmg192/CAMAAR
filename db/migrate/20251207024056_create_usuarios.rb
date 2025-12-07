class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :login
      t.string :email
      t.string :matricula
      t.string :password_digest

      t.timestamps
    end
  end
end
