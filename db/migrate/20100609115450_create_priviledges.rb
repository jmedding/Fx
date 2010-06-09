class CreatePriviledges < ActiveRecord::Migration
  def self.up
    create_table :priviledges do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :level_id

      t.timestamps
    end
  end

  def self.down
    drop_table :priviledges
  end
end
