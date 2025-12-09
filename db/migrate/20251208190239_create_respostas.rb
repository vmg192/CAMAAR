class CreateRespostas < ActiveRecord::Migration[8.0]
  def change
    create_table :respostas do |t|
      t.text :conteudo
      t.text :snapshot_enunciado
      t.json :snapshot_opcoes
      t.references :submissao, null: false, foreign_key: true
      t.references :pergunta, null: false, foreign_key: true

      t.timestamps
    end
  end
end
