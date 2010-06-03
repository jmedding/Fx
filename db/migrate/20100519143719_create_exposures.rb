class CreateExposures < ActiveRecord::Migration
  def self.up
    create_table :exposures do |t|
      t.integer :tender_id
      t.integer :currency_in
      t.integer :currency_out
      t.float :carried_rate
      t.float :current_rate
      t.integer :amount
      t.boolean :supply
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :exposures
  end
end
