class CreateAdvertisements < ActiveRecord::Migration[5.2]
  def change
    create_table :advertisements do |t|
      t.integer :lot_id
      t.string :body

      t.timestamps
    end
  end
end
