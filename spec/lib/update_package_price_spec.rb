# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdatePackagePrice do
  it "updates the current price of the provided package" do
    package = Package.create!(name: "Dunderhonung")

    UpdatePackagePrice.call(package, 200_00)
    expect(package.reload.amount_cents).to eq(200_00)
  end

  it "only updates the passed package price" do
    package = Package.create!(name: "Dunderhonung")
    other_package = Package.create!(name: "Farmors köttbullar", amount_cents: 100_00)

    expect {
      UpdatePackagePrice.call(package, 200_00)
    }.not_to change {
      other_package.reload.amount_cents
    }
  end

  it "stores the old price of the provided package in its price history" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)

    UpdatePackagePrice.call(package, 200_00)
    expect(package.prices.count).to eq(2)
    price = package.prices.first
    expect(price.amount_cents).to eq(100_00)
  end

  it 'stores price for municipality' do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: 'Stockholm')

    UpdatePackagePrice.call(package, 200_00, municipality: municipality)

    expect(package.reload.amount_cents).to eq(100_00)
    expect(municipality.reload.amount_cents).to eq(200_00)
  end

  it 'stores price for municipality and can overwrite global' do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: 'Stockholm')

    UpdatePackagePrice.call(package, 200_00, municipality: municipality, overwrite_global: true)
    UpdatePackagePrice.call(package, 300_00)

    expect(package.reload.amount_cents).to eq(300_00)
    expect(municipality.reload.amount_cents).to eq(200_00)
  end

  it 'stores price for municipality and can disable overwriting global' do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: 'Stockholm')

    UpdatePackagePrice.call(package, 200_00, municipality: municipality, overwrite_global: true)
    UpdatePackagePrice.call(package, 300_00)
    UpdatePackagePrice.call(package, 250_00, municipality: municipality)

    expect(package.reload.amount_cents).to eq(300_00)
    expect(municipality.reload.amount_cents).to eq(250_00)

    UpdatePackagePrice.call(package, 500_00)

    expect(package.reload.amount_cents).to eq(500_00)
    expect(municipality.reload.amount_cents).to eq(500_00)
  end
end
