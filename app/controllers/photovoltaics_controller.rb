class PhotovoltaicsController < ApplicationController
  require "json"
  require "open-uri"
  SUN_TIMES = [8, 9, 10, 11, 14, 16, 15, 14, 12, 10, 9, 7]

  def new
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new
  end

  def create
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new(photovoltaic_params)
    @photovoltaic_new.home_id = @home.id
    (1..12).each do |ratio|
      @photovoltaic_new.ratio_months[ratio - 1] = params[:ratio][:ratio_months]["#{ratio}"].to_i
    end
    # Ligne à remplacer avec nouvelle méthode liée à l'API :
    # production_calculation(@photovoltaic_new)
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
    # Ligne à remplacer avec nouvelle méthode liée à l'API :
    # production_calculation(@photovoltaic)
    photovoltaic_production_pvgis(@photovoltaic)
    self_consumption_calculation(@home, @photovoltaic)
    back_energy_calculation(@photovoltaic)
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

  def production_calculation(photovoltaic)
    (0..11).each do |month|
      photovoltaic.production_months[month] = (photovoltaic.power * photovoltaic.ratio_months[month]).to_i
    end
  end

  def photovoltaic_production_pvgis(photovoltaic)
    url = "https://re.jrc.ec.europa.eu/api/PVcalc?lat=45.815&lon=8.611&peakpower=#{photovoltaic.power}&loss=12"
    data_pvgis_serialized = URI.open(url).read
    data_pvgis_lines = data_pvgis_serialized.split("\r\n")[10..21]
    data_pvgis_array = data_pvgis_lines.map{ |line| line.split("\t") }
    data_pvgis_array.map! { |data| data.reject(&:empty?) }
    photovoltaic_production = []
    data_pvgis_array.each do |data_month|
      photovoltaic_production << data_month[2]
    end
    raise
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
        photovoltaic.self_consumption_months[month] = (instant_power_consumption[month] / photovoltaic.power) * photovoltaic.production_months[month]
      # sinon la puissance crète est alors inférieure à la conso de base :
      else
        photovoltaic.self_consumption_months[month] = photovoltaic.production_months[month]
      end
    end
  end

  def back_energy_calculation(photovoltaic)
    (0..11).each do |month|
      photovoltaic.back_energy_months[month] = photovoltaic.production_months[month] - photovoltaic.self_consumption_months[month]
    end
  end
end
