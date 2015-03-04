class AddHelperCheckinIndexes < ActiveRecord::Migration
  def change
    add_index :helper_checkins, :person_id
    change_column_null :helper_checkins, :person_id, false
  end
end
