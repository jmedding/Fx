class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :password
      t.integer :rating
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
