class PhotovoltaicsController < ApplicationController
  require "open-uri"

  def new
    @home = Home.find(params[:home_id])
    @photovoltaic_project = Photovoltaic.new
    @power = params[:power]
    # @photovoltaic_project.photovoltaic_production_pvgis(@home)
    # @photovoltaic_project.self_consumption_calculation(@home)
    # @photovoltaic_project.back_energy_calculation
    # @photovoltaic_project.economics_calculation(@home)
  end

  def show
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
  end

  def create
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new(photovoltaic_params)
    @photovoltaic_new.home_id = @home.id

    @photovoltaic_new.photovoltaic_production_pvgis(@home)
    @photovoltaic_new.self_consumption_calculation(@home)
    @photovoltaic_new.back_energy_calculation
    @photovoltaic_new.economics_calculation(@home)

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

    @photovoltaic.photovoltaic_production_pvgis(@home)
    @photovoltaic.self_consumption_calculation(@home)
    @photovoltaic.back_energy_calculation
    @photovoltaic.economics_calculation(@home)

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

end
