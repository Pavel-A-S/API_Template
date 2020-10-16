class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.integer :item_id
      t.integer :storage_id
      t.integer :amount
      t.integer :price
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :lots, %i[item_id storage_id status], unique: true
  end
end
