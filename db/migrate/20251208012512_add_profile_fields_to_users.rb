class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :login, :string
    add_index :users, :login, unique: true
    add_column :users, :matricula, :string
    add_index :users, :matricula, unique: true
    add_column :users, :nome, :string
    add_column :users, :formacao, :string
    add_column :users, :eh_admin, :boolean, default: false
  end
end
