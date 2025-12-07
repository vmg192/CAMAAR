class CreateUsuarios < ActiveRecord::Migration[8.0] # ou [7.1] dependendo da sua versão
  def change
    create_table :usuarios do |t|
      t.string :login
      t.string :matricula
      t.string :nome              # Adicionado (Tarefa #5)
      t.string :email
      t.string :formacao          # Adicionado (Tarefa #5)
      t.string :password_digest   # Mantivemos o padrão do Rails
      t.boolean :eh_admin, default: false # Adicionado (Tarefa #5)

      t.timestamps
    end

    # Adicionando restrição de unicidade direto no Banco de Dados (Tarefa #5)
    add_index :usuarios, :login, unique: true
    add_index :usuarios, :matricula, unique: true
    add_index :usuarios, :email, unique: true
  end
end