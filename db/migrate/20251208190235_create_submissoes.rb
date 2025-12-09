class CreateSubmissoes < ActiveRecord::Migration[8.0]
  def change
    create_table :submissoes do |t|
      t.datetime :data_envio
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      t.references :avaliacao, null: false, foreign_key: true

      t.timestamps
    end
  end
end
