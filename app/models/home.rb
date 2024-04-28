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

  def handle_uploaded_csv(file)
    linky_data = []
    CSV.foreach(file, encoding: 'utf-8') do |row|
      linky_data << row
    end
    filtered_data = linky_data.select { |row| row[0]&.start_with?(/^\d/) }
    filtered_data.map! { |row| row[0].split(';').slice(0, 2) }
    filtered_data.select! { |row| row[0].include?("2023") }
    self.home_consumption_months = filtered_data.map { |row| row[1].to_i }.reverse
  end

  def price_consumption_calculation
    (0..11).each do |month|
      self.price_consumption_months[month] = (self.home_consumption_months[month] * self.buy_price_electricity).round(2)
    end
  end

  private
  def update_photovoltaics
    photovoltaics.each(&:update_attributes_dependent_on_home)
  end

end
