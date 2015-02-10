class CreateHelpRequests < ActiveRecord::Migration
  def change
    create_table :help_requests do |t|
      t.belongs_to :enrollment
      t.text :description
      t.string :location
      t.boolean :open, default: true

      t.timestamps null: false
    end
  end
end
