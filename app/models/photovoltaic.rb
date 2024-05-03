class Photovoltaic < ApplicationRecord

  # en kWc par panneau :
  POWER_BY_PANEL = 0.43
  # en m2 par panneau :
  AREA_BY_PANEL = 1.85
  # prix du panneau par kWc :
  PANEL_PRICE = 3500

  belongs_to :home

  validates :panel_number, presence: true, numericality: { greater_than: 0 }

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
    # TODO : issue n° 31
  end

  def power_calculation
    self.power = self.panel_number * POWER_BY_PANEL
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
      instant_power_consumption[month] = (home.home_consumption_months[month] * 100 * 12 / 365 / 24) / 100.to_f
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
    # hypothèse 3 : calcul de l'investissement = power(kWc) * 3500 -> produit + installation
    self.investment = (self.power * PANEL_PRICE).to_i
    self.roi = (self.investment / (self.self_electricity_months.sum + self.sale_electricity_months.sum)).round(1)
    # hypothèse 4 : calcul du profit final sur une base de durée de vie de panneau de 45 ans
    self.profit = (((self.self_electricity_months.sum + self.sale_electricity_months.sum) * 45) - self.investment).to_i
    self.annual_performance = ((self.self_electricity_months.sum + self.sale_electricity_months.sum) / self.investment * 100).round(2)
    self.global_performance = (((self.investment + self.profit) - self.investment) / self.investment * 100).round(2)
  end

  def investment_project(investment_amount, installation_surface)
    panel_number = (investment_amount / (PANEL_PRICE * POWER_BY_PANEL)).to_i
    surface = panel_number * AREA_BY_PANEL
    if surface > installation_surface
      panel_number = (installation_surface / AREA_BY_PANEL).to_i
    end
    return panel_number
  end

  def autonomy_project(home, installation_surface)
    # voir hypothèse 2
    # il faut trouver le maximum de photovoltaic.self_consumption_months.sum
    project_power = POWER_BY_PANEL
    project_surface = AREA_BY_PANEL
    project_self_energy = [0]
    i = 0
    while project_surface < installation_surface
      i += 1
      self.power = project_power
      self.photovoltaic_production_pvgis(home)
      self.self_consumption_calculation(home)
      project_self_energy << self.self_consumption_months.sum.to_i

      if project_self_energy[i] == project_self_energy[i - 1]
        # return car on est à l'optimal max : i - 1 est le bon
        return panel_number = i - 1
      end

      project_power += POWER_BY_PANEL
      project_surface += AREA_BY_PANEL
    end
    # return le cas où c'est la surface le limitant
    return panel_number = i
  end

  def bill_project(home, reduce_bill, installation_surface)
    # on va raisonner sur l'année, on doit avoir (self_electricity_months.sum + sale_electricity_months.sum) au moins égal à (reduce_bill * 12)
    reduce_bill *= 12
    project_power = POWER_BY_PANEL
    project_surface = AREA_BY_PANEL
    project_bill = [0]
    i = 0
    while project_surface < installation_surface
      i += 1
      self.power = project_power
      self.photovoltaic_production_pvgis(home)
      self.self_consumption_calculation(home)
      self.back_energy_calculation
      self.economics_calculation(home)
      project_bill << (self.self_electricity_months.sum + self.sale_electricity_months.sum).to_i

      if project_bill[i] > reduce_bill
        # return car on est à l'objectif de réduction
        return panel_number = i
      end

      project_power += POWER_BY_PANEL
      project_surface += AREA_BY_PANEL
    end
    # return le cas où c'est la surface le limitant
    return panel_number = i
  end

end
