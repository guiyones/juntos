class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.references :challenge, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.string :person_token, null: false
      t.timestamps
    end
    add_index :participants, [ :challenge_id, :person_token ], unique: true
  end
end
