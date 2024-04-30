class PhotovoltaicsController < ApplicationController
  require "open-uri"

  PROJECT_NAMES = ["Meilleur investissement", "Maximum d'autonomie", "Moins sur la facture!"]

  def new
    @project_type = params[:project_type]
    @home = Home.find(params[:home_id])
    @photovoltaic_project = Photovoltaic.new(panel_number: params[:panel_number])
    @photovoltaic_project.power_calculation
    @photovoltaic_project.photovoltaic_production_pvgis(@home)
    @photovoltaic_project.self_consumption_calculation(@home)
    @photovoltaic_project.back_energy_calculation
    @photovoltaic_project.economics_calculation(@home)
  end

  def show
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
  end

  def create
    @home = Home.find(params[:home_id])
    @photovoltaic_new = Photovoltaic.new(photovoltaic_params)
    @photovoltaic_new.home_id = @home.id
    if params[:photovoltaic][:project_type].present?
      @photovoltaic_new.power_calculation
      @photovoltaic_new.name = PROJECT_NAMES[params[:photovoltaic][:project_type].to_i]
      @photovoltaic_new.production_months = params[:photovoltaic][:production_months].split(' ').map(&:to_f)
    else
      @photovoltaic_new.power_calculation
      @photovoltaic_new.name = "Installation de #{@photovoltaic_new.panel_number} panneaux"
      @photovoltaic_new.photovoltaic_production_pvgis(@home)
    end

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
    @photovoltaic.power_calculation
    @photovoltaic.name = "Installation de #{@photovoltaic.panel_number} panneaux"
    @photovoltaic.photovoltaic_production_pvgis(@home)
    @photovoltaic.self_consumption_calculation(@home)
    @photovoltaic.back_energy_calculation
    @photovoltaic.economics_calculation(@home)

    @photovoltaic.save
    redirect_to home_path(@home), alert: "Nouvelle installation de #{@photovoltaic.panel_number}€"
  end

  def destroy
    @home = Home.find(params[:home_id])
    @photovoltaic = Photovoltaic.find(params[:id])
    @photovoltaic.destroy
    redirect_to home_path(@home), status: :see_other
  end

  private

  def photovoltaic_params
    params.require(:photovoltaic).permit(:panel_number)
  end

end
