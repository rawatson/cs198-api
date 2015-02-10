class StringGenders < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.change :gender, :string
    end
  end
end
