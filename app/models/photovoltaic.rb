class Photovoltaic < ApplicationRecord

  # en kWc par panneau :
  POWER_BY_PANEL = 0.43
  # en m2 par panneau :
  AREA_BY_PANEL = 1.85

  belongs_to :home

  validates :power, presence: true

  def update_attributes_dependent_on_home
    home = self.home
    # si on change l'adresse de home :
    self.photovoltaic_production_pvgis(home)
    # si l'on change les données de consommation de home :
    self.self_consumption_calculation(home)
    # si l'on fait au moins un des chgts ci-dessus :
    self.back_energy_calculation
    # si l'on change Notamment le prix de l'élec :
    self.economics_calculation(home)

    self.save
  end

  def photovoltaic_production_pvgis(home)
    url = "https://re.jrc.ec.europa.eu/api/PVcalc?lat=#{home.latitude}&lon=#{home.longitude}&peakpower=#{self.power}&loss=14"
    data_pvgis_serialized = URI.open(url).read
    data_pvgis_lines = data_pvgis_serialized.split("\r\n")[10..21]
    data_pvgis_array = data_pvgis_lines.map{ |line| line.split("\t") }
    data_pvgis_array.map! { |data| data.reject(&:empty?) }
    data_pvgis_array.each_with_index do |data_month, month|
      self.production_months[month] = data_month[2].to_f
    end
  end

  def self_consumption_calculation(home)
    # hypothèse 1 : consommation instantanée socle du bien est constante et égale à = (consommation mensuelle * 12/365) / 24
    instant_power_consumption = []
    (0..11).each do |month|
      instant_power_consumption[month] = (home.home_consumption_months[month] * 100 * 12 / 365 / 24)/100.to_f
    end
    # hypothèse 2 : courbe de production est de type créneau
    (0..11).each do |month|
      # si la puissance crète est supérieure à la conso de base :
      if self.power > instant_power_consumption[month]
        self.self_consumption_months[month] = ((instant_power_consumption[month] / self.power) * self.production_months[month]).round(2)
      # sinon la puissance crète est alors inférieure à la conso de base :
      else
        self.self_consumption_months[month] = self.production_months[month]
      end
    end
  end

  def back_energy_calculation
    (0..11).each do |month|
      self.back_energy_months[month] = (self.production_months[month] - self.self_consumption_months[month]).round(2)
    end
  end

  def economics_calculation(home)
    (0..11).each do |month|
      self.self_electricity_months[month] = (self.self_consumption_months[month] * home.buy_price_electricity).round(2)
      self.sale_electricity_months[month] = (self.back_energy_months[month] * home.sale_price_electricity).round(2)
    end
    # hypothèse : calcul de l'investissement = power(kWc) * 3500 -> produit + installation
    self.investment = (self.power * 3500).to_i
    self.roi = (self.investment / (self.self_electricity_months.sum + self.sale_electricity_months.sum)).round(1)
    # hypothèse : calcul du profit final sur une base de durée de vie de panneau de 45 ans
    self.profit = (((self.self_electricity_months.sum + self.sale_electricity_months.sum) * 45) - self.investment).to_i
    self.annual_performance = ((self.self_electricity_months.sum + self.sale_electricity_months.sum) / self.investment * 100).round(2)
    self.global_performance = (((self.investment + self.profit) - self.investment) / self.investment * 100).round(2)
  end
end
