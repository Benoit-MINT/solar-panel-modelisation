class Home < ApplicationRecord
  has_many :photovoltaics

  validates :name, presence: :true
  validates :address, presence: :true
  validates :home_consumption_months, presence: true
  validates :home_consumption_months, length: { is: 12 }

  geocoded_by :address
  # on limite les appels sur l'API :
  after_validation :geocode, if: :will_save_change_to_address?

end
