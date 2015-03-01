class CreateHelperShifts < ActiveRecord::Migration
  def change
    create_table :helper_shifts do |t|
      t.datetime :start_time,   null: false
      t.integer :duration,      null: false # in seconds
      t.boolean :regular_shift, null: false, default: true
      t.belongs_to :person,     required: true

      t.timestamps null: false
    end
  end
end
