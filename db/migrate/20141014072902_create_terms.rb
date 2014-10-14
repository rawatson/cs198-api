class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.string :year, null: false
      t.string :title, null: false

      t.timestamps null: false
    end
  end
end
