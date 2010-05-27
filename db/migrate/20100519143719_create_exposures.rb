class CreateExposures < ActiveRecord::Migration
  def self.up
    create_table :exposures do |t|
      t.integer :tender_id
      t.integer :currency_in
      t.integer :currency_out
      t.float :factor
      t.integer :amount
      t.boolean :supply

      t.timestamps
    end
  end

  def self.down
    drop_table :exposures
  end
end
