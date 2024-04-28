class Photovoltaic < ApplicationRecord

  # en kWc par panneau :
  POWER_BY_PANEL = 0.43
  # en m2 par panneau :
  AREA_BY_PANEL = 1.85

  belongs_to :home

  validates :power, presence: true

  # Plus nécessaire avec recours à l'API PVGIS
  # validates :ratio_months, presence: true
end
