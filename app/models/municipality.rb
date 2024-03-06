class Municipality < ApplicationRecord
  has_many :prices, dependent: :destroy

  validates :name, presence: true

  def amount_cents
    last_local = self.prices.last

    if last_local.overwrite_global
      last_local.amount_cents
    else
      Price.where(municipality_id: self.id).or(Price.where(municipality_id: nil)).last.amount_cents
    end
  end
end
