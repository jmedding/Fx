class CreateData < ActiveRecord::Migration
  def self.up
    create_table :data do |t|
      t.integer :conversion_id
      t.float :rate
      t.date :day

      t.timestamps
    end
  end

  def self.down
    drop_table :data
  end
end
