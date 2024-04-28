class Home < ApplicationRecord
  has_many :photovoltaics, dependent: :destroy

  validates :name, presence: :true
  validates :address, presence: :true
  validates :home_consumption_months, presence: true
  validates :home_consumption_months, length: { is: 12 }
  validates :buy_price_electricity, presence: true
  validates :sale_price_electricity, presence: true

  geocoded_by :address
  # on limite les appels sur l'API :
  after_validation :geocode, if: :will_save_change_to_address?

  after_update :update_photovoltaics

  private
  def update_photovoltaics
    photovoltaics.each(&:update_attributes_dependent_on_home)
  end

end
