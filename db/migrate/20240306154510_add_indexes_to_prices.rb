class AddIndexesToPrices  < ActiveRecord::Migration[7.1]
  def change
    add_index(:prices, [:package, 'strftime(\'%Y\', created_at)', :municipality_id])
  end
end
