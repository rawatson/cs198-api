class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :code
      t.string :title
      t.string :website
      t.string :registry_doc_name
      t.references :term

      t.timestamps null: false
    end
  end
end
