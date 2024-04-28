class PhotovoltaicsController < ApplicationController
  require "open-uri"

  def new
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new
  end

  def show
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
  end

  def create
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new(photovoltaic_params)
    @photovoltaic_new.home_id = @home.id

    photovoltaic_production_pvgis(@home, @photovoltaic_new)
    self_consumption_calculation(@home, @photovoltaic_new)
    back_energy_calculation(@photovoltaic_new)

    if @photovoltaic_new.save
      redirect_to home_path(@home), alert: "L'installation est créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
  end

  def update
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
    @photovoltaic.update(photovoltaic_params)

    photovoltaic_production_pvgis(@home, @photovoltaic)
    self_consumption_calculation(@home, @photovoltaic)
    back_energy_calculation(@photovoltaic)
    economics_calculation(@home, @photovoltaic)

    @photovoltaic.save
    redirect_to home_path(@home), alert: "Nouvelle puissance d'installation #{params[:photovoltaic][:power]}€"
  end

  def destroy
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
    @photovoltaic.destroy
    redirect_to home_path(@home), status: :see_other
  end


  private

  def photovoltaic_params
    params.require(:photovoltaic).permit(:power)
  end

  def photovoltaic_production_pvgis(home, photovoltaic)
    url = "https://re.jrc.ec.europa.eu/api/PVcalc?lat=#{home.latitude}&lon=#{home.longitude}&peakpower=#{photovoltaic.power}&loss=14"
    data_pvgis_serialized = URI.open(url).read
    data_pvgis_lines = data_pvgis_serialized.split("\r\n")[10..21]
    data_pvgis_array = data_pvgis_lines.map{ |line| line.split("\t") }
    data_pvgis_array.map! { |data| data.reject(&:empty?) }
    data_pvgis_array.each_with_index do |data_month, month|
      photovoltaic.production_months[month] = data_month[2].to_f
    end
  end

  def self_consumption_calculation(home, photovoltaic)
    # hypothèse 1 : consommation instantanée socle du bien est constante et égale à = (consommation mensuelle * 12/365) / 24
    instant_power_consumption = []
    (0..11).each do |month|
      instant_power_consumption[month] = (home.home_consumption_months[month] * 100 * 12 / 365 / 24)/100.to_f
    end
    # hypothèse 2 : courbe de production est de type créneau
    (0..11).each do |month|
      # si la puissance crète est supérieure à la conso de base :
      if photovoltaic.power > instant_power_consumption[month]
        photovoltaic.self_consumption_months[month] = ((instant_power_consumption[month] / photovoltaic.power) * photovoltaic.production_months[month]).round(2)
      # sinon la puissance crète est alors inférieure à la conso de base :
      else
        photovoltaic.self_consumption_months[month] = photovoltaic.production_months[month]
      end
    end
  end

  def back_energy_calculation(photovoltaic)
    (0..11).each do |month|
      photovoltaic.back_energy_months[month] = (photovoltaic.production_months[month] - photovoltaic.self_consumption_months[month]).round(2)
    end
  end

  def economics_calculation(home, photovoltaic)
    (0..11).each do |month|
      photovoltaic.self_electricity_months[month] = (photovoltaic.self_consumption_months[month] * home.buy_price_electricity).round(2)
      photovoltaic.sale_electricity_months[month] = (photovoltaic.back_energy_months[month] * home.sale_price_electricity).round(2)
    end
    # hypothèse : calcul de l'investissement = power(kWc) * 3500 -> produit + installation
    photovoltaic.investment = (photovoltaic.power * 3500).to_i
    photovoltaic.roi = (photovoltaic.investment / (photovoltaic.self_electricity_months.sum + photovoltaic.sale_electricity_months.sum)).round(1)
    # hypothèse : calcul du profit final sur une base de durée de vie de panneau de 45 ans
    photovoltaic.profit = (((photovoltaic.self_electricity_months.sum + photovoltaic.sale_electricity_months.sum) * 45) - photovoltaic.investment).to_i
    photovoltaic.annual_performance = ((photovoltaic.self_electricity_months.sum + photovoltaic.sale_electricity_months.sum) / photovoltaic.investment * 100).round(2)
    photovoltaic.global_performance = (((photovoltaic.investment + photovoltaic.profit) - photovoltaic.investment) / photovoltaic.investment * 100).round(2)
  end
end
