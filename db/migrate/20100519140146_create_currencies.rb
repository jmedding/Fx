class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :symbol
		t.boolean :base,		:default => false
		t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :currencies
  end
end
