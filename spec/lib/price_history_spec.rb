# frozen_string_literal: true

require "spec_helper"

RSpec.describe PriceHistory do
  it "fetches price for all munitipalities" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: 'Stockholm')

    UpdatePackagePrice.call(package, 200_00, municipality: municipality, overwrite_global: true)
    UpdatePackagePrice.call(package, 300_00)
    UpdatePackagePrice.call(package, 250_00, municipality: municipality)
    UpdatePackagePrice.call(package, 500_00)

    expect(PriceHistory.call(package, Date.today.year)).to eq({'Global': [10000, 30000, 50000], 'Stockholm': [10000, 20000, 25000, 50000]})
  end

  it "fetches price for specific munitipality" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality_1 = Municipality.create!(name: 'Stockholm')
    municipality_2 = Municipality.create!(name: 'Uppsala')

    UpdatePackagePrice.call(package, 201_00, municipality: municipality_1)
    UpdatePackagePrice.call(package, 202_00, municipality: municipality_2)
    UpdatePackagePrice.call(package, 300_00)

    expect(PriceHistory.call(package, Date.today.year, municipality_1))
      .to eq({'Stockholm': [10000, 20100, 30000]})
  end

  it "fetches price for specific package" do
    package_1 = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    package_2 = Package.create!(name: "Bamse", amount_cents: 150_00)

    municipality = Municipality.create!(name: 'Stockholm')

    UpdatePackagePrice.call(package_1, 200_00, municipality: municipality)
    UpdatePackagePrice.call(package_2, 250_00, municipality: municipality)
    UpdatePackagePrice.call(package_1, 300_00)

    expect(PriceHistory.call(package_1, Date.today.year))
      .to eq({'Global': [10000, 30000], 'Stockholm': [10000, 20000, 30000]})
  end

  it "fetches price for specific year" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)

    municipality = Municipality.create!(name: 'Stockholm')

    Price.create!(package: package, amount_cents: 20000, municipality: municipality, created_at: Date.today - 1.year)
    Price.create!(package: package, amount_cents: 30000, municipality: municipality)

    expect(PriceHistory.call(package, Date.today.year))
      .to eq({'Global': [10000], 'Stockholm': [10000, 30000]})
  end
end
