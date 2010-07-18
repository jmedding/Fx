class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :currency_id
      t.integer :rules_id
      t.integer :type_id
      t.float :payment, 	:default => 0
      t.integer :period, 	:default => 1
      t.string :ccnum
      t.date :cc_exp
      t.string :cc_name
      t.string :paypal
      t.integer :address_id
      t.integer :external_id
      t.integer :creator_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
