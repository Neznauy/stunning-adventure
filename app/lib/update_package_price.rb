# frozen_string_literal: true

class UpdatePackagePrice
  def self.call(package, new_price_cents, **options)
    Package.transaction do
      # Add a pricing history record
      Price.create!(
        package: package,
        amount_cents: new_price_cents,
        municipality: options[:municipality],
        overwrite_global: options[:overwrite_global]
      )

      # Update the current global price
      package.update!(amount_cents: new_price_cents) unless options[:municipality]
    end
  end
end
