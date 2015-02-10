class EnrollmentsCompoundIndex < ActiveRecord::Migration
  def change
    add_index :enrollments, [:person_id, :course_id]
  end
end
