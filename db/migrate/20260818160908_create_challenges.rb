class CreateChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :challenges do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :starts_on, null: false
      t.integer :days, null: false
      t.string :token, null: false
      t.timestamps
    end
    add_index :challenges, :token, unique: true
  end
end
