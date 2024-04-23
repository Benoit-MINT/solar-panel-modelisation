class Photovoltaic < ApplicationRecord
  belongs_to :home

  validates :power, presence: true
end
