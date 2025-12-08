class CreateAvaliacoes < ActiveRecord::Migration[8.0]
  def change
    create_table :avaliacoes do |t|
      t.references :turma, null: false, foreign_key: true
      t.references :modelo, null: false, foreign_key: true
      t.references :professor_alvo, null: true, foreign_key: { to_table: :users }
      t.datetime :data_inicio
      t.datetime :data_fim

      t.timestamps
    end
  end
end
