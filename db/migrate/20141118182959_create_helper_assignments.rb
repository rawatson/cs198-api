class CreateHelperAssignments < ActiveRecord::Migration
  def change
    create_table :helper_assignments do |t|
      t.belongs_to :helper_checkin
      t.belongs_to :help_request
      t.timestamp :claim_time, null: false
      t.timestamp :close_time
      t.string :close_status
      t.references :reassignment
      t.text :student_feedback
      t.text :helper_feedback

      t.timestamps null: false
    end
  end
end
