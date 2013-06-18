class AddCodeToClassrooms < ActiveRecord::Migration
  def up
  	add_column :classrooms, :code, :string
  end

  def down
  	remove_column :classrooms, :code
  end
end
