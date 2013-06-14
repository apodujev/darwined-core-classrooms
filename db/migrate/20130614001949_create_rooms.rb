class CreateRooms < ActiveRecord::Migration
  def up
    create_table :rooms do |t|
      t.string :name
      t.integer :capacity

      t.timestamps
    end
  end

  def down
    drop_table :room
  end
end
