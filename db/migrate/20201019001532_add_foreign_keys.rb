class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :players, :storages
    add_foreign_key :lots, :storages
    add_foreign_key :lots, :items
    add_foreign_key :advertisements, :lots
  end
end
