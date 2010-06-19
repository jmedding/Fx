class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
		t.string :login,								:null => false
      t.string :crypted_password,		:null => false
		t.string :password_salt,				:null => false
		t.string :persistence_token,		:null => false
		t.string :email,								:null => false
      t.integer :rating
      t.integer :group_id
		t.integer :login_count, 				:null => false, :default => 0
		t.integer :failed_login_count, 	:null => false, :default => 0
		t.datetime :last_request_at
		t.datetime :last_login_at
		t.datetime :current_login_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
