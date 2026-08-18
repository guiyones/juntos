class CreateCheckins < ActiveRecord::Migration[8.1]
  def change
    create_table :checkins do |t|
      t.references :participant, null: false, foreign_key: true
      t.date :date, null: false
      t.timestamps
    end
    add_index :checkins, [ :participant_id, :date ], unique: true
  end
end
