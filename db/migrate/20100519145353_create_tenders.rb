class CreateTenders < ActiveRecord::Migration
  def self.up
    create_table :tenders do |t|
      t.integer :project_id
      t.integer :group_id
      t.date :bid_date
      t.date :validity
      t.integer :user_id
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tenders
  end
end
