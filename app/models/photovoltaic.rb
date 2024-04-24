class Photovoltaic < ApplicationRecord
  belongs_to :home

  validates :power, presence: true
  validates :ratio_months, presence: true
end
