class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.text :content
      t.string :author

      t.timestamps
    end
  end
end
