class CreateConversions < ActiveRecord::Migration
  def self.up
    create_table :conversions do |t|
      t.integer :currency_in
      t.integer :currency_out
      t.date :first
      t.date :last

      t.timestamps
    end
  end

  def self.down
    drop_table :conversions
  end
end
