class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :nickname
      t.integer :currency_amount
      t.integer :storage_id

      t.timestamps
    end
  end
end
