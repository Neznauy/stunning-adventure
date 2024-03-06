class AddMunicipalitiesToPrices  < ActiveRecord::Migration[7.1]
  def change
    add_reference :prices, :municipality, null: true
    add_column :prices, :overwrite_global, :boolean
  end
end
