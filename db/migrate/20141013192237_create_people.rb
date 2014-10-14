class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :suid
      t.string :sunet_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :nick_name
      t.string :email, null: false
      t.string :phone_number
      t.boolean :gender
      t.boolean :scpd
      t.boolean :staff, null: false
      t.boolean :active
      t.string :citizen_status
      t.timestamp :hire_date

      t.timestamps null: false
    end

    add_index :people, :sunet_id, unique: true
    add_index :people, :suid, unique: true
  end
end
