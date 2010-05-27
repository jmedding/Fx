class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
	t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
