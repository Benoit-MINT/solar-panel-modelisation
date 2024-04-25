class PhotovoltaicsController < ApplicationController
  SUN_TIMES = [9, 10, 11, 13, 14, 16, 16, 14, 13, 11, 10, 9]

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
    production_calculation(@photovoltaic_new)
    self_consumption_calculation(@home, @photovoltaic_new)
    back_energy_calculation(@photovoltaic)
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
    production_calculation(@photovoltaic)
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

  def self_consumption_calculation(home, photovoltaic)
    # hypothèse 1 : consommation instantanée socle du bien est constante et égale à = (consommation mensuelle * 12/365) / 24
    instant_power_consumption = []
    (0..11).each do |month|
      instant_power_consumption[month] = (home.home_consumption_months[month] * 100 * 12 / 365 / 24)/100.to_f
    end
    # hypothèse 2 : courbe de production est de type créneau, où Pmax = Pcrète, et t = (temps ensoleillement / 2)
    # donc : t correspond à la période où l'énergie solaire produite est consommée par le bien
    (0..11).each do |month|
      photovoltaic.self_consumption_months[month] = (instant_power_consumption[month] * (SUN_TIMES[month] / 2) * (365/12)).to_i
    end
  end

  def back_energy_calculation(photovoltaic)
    (0..11).each do |month|
      photovoltaic.back_energy_months[month] = photovoltaic.production_months[month] - photovoltaic.self_consumption_months[month]
    end
  end
end
