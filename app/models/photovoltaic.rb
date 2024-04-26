class Photovoltaic < ApplicationRecord
  belongs_to :home

  validates :power, presence: true

  # Plus nécessaire avec recours à l'API PVGIS
  # validates :ratio_months, presence: true
end
