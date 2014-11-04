class CreateHelperCheckins < ActiveRecord::Migration
  def change
    create_table :helper_checkins do |t|
      t.belongs_to :person
      t.boolean :checked_out, default: false, null: false

      t.timestamps
    end
    add_index :helper_checkins, :checked_out
  end
end
