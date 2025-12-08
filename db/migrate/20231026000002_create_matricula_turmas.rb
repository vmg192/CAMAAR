class CreateMatriculaTurmas < ActiveRecord::Migration[7.0]
  def change
    create_table :matricula_turmas do |t|
      t.references :user, null: false, foreign_key: true
      t.references :turma, null: false, foreign_key: true
      t.string :papel

      t.timestamps
    end
  end
end
