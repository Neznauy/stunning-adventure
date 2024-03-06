# frozen_string_literal: true

class PriceHistory
  def self.call(package, year, municipality = nil)
    relation = Price.eager_load(:municipality)
      .where(package_id: package.id)
      .where('strftime(\'%Y\', prices.created_at) = ?', year.to_s)

    relation = relation.where(municipality_id: [nil, municipality.id]) unless municipality.nil?

    raw = relation.pluck(:amount_cents, :created_at, :name, :overwrite_global)
      .map { |price| OpenStruct.new(price: price[0], created_at: price[1], name: price[2], overwrite: price[3]) }
      .group_by { |price| price.name }

    global_prices = raw[nil]

    result = municipality.nil? ? {'Global': global_prices.map(&:price) } : {}

    raw.keys.compact.each do |m|
      result[m.to_sym] = merged_municipality_prices(global_prices, raw[m])
    end

    result
  end

  private

  def self.merged_municipality_prices(global, local)
    merged_prices = []
    overwrite = false

    local.concat(global).sort_by { |price| price.created_at }.each do |p|
      if p.name.nil?
        merged_prices << p.price unless overwrite
      else
        merged_prices << p.price

        overwrite = p.overwrite
      end
    end

    merged_prices
  end
end
