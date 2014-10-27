class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.belongs_to :person
      t.belongs_to :course
      t.string :position
      t.integer :seniority
    end
  end
end
