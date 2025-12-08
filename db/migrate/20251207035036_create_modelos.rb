class CreateModelos < ActiveRecord::Migration[8.0]
  def change
    create_table :modelos do |t|
      t.string :titulo
      t.boolean :ativo, default: true

      t.timestamps
    end
  end
end
