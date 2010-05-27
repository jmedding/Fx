class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.integer :exposure_id
      t.float :factor
      t.string :description
      t.float :carried
      t.date :day

      t.timestamps
    end
  end

  def self.down
    drop_table :rates
  end
end
