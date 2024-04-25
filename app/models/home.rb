class Home < ApplicationRecord
  has_many :photovoltaics

  validates :name, presence: :true
  validates :address, presence: :true
  validates :home_consumption_months, presence: true
  validates :home_consumption_months, length: { is: 12 }
end
