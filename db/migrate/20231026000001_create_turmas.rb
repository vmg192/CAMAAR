class CreateTurmas < ActiveRecord::Migration[7.0]
  def change
    create_table :turmas do |t|
      t.string :codigo
      t.string :nome
      t.string :semestre

      t.timestamps
    end
  end
end
