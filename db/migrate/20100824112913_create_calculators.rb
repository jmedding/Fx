class CreateCalculators < ActiveRecord::Migration
  def self.up
    create_table :calculators do |t|
      t.string :from
      t.string :to
      t.integer :duration
      t.string :session_id
      t.integer :source_id
		t.float :provision
		t.integer :conversion_id
		t.integer :invert

      t.timestamps
    end
  end

  def self.down
    drop_table :calculators
  end
end
