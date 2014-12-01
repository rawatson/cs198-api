class CreateLairStates < ActiveRecord::Migration
  def change
    create_table :lair_states do |t|
      t.boolean :signups_enabled, null: false, default: false

      t.timestamps null: false
    end
  end
end
