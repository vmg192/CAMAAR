class CreatePerguntas < ActiveRecord::Migration[8.0]
  def change
    create_table :perguntas do |t|
      t.text :enunciado
      t.string :tipo
      t.json :opcoes
      t.references :modelo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
