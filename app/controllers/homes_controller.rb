class HomesController < ApplicationController
  require "csv"

  def index
    @homes = Home.all
    @home_new = Home.new
  end

  def show
    @home = Home.find(params[:id])
    @photovoltaic_new = Photovoltaic.new

    if params[:investment].present?
      @panel_number = @photovoltaic_new.investment_project(params[:investment][:investment_amount].to_i, params[:investment][:installation_surface].to_i)
      redirect_to new_home_photovoltaic_path(@home, panel_number: @panel_number, project_type: 0)
    end

    if params[:autonomy].present?
      @panel_number = @photovoltaic_new.autonomy_project(@home, params[:autonomy][:installation_surface].to_i)
      redirect_to new_home_photovoltaic_path(@home, panel_number: @panel_number, project_type: 1)
    end

    if params[:bill].present?
      @panel_number = @photovoltaic_new.bill_project(@home, params[:bill][:reduce_bill].to_i, params[:bill][:installation_surface].to_i)
      redirect_to new_home_photovoltaic_path(@home, panel_number: @panel_number, project_type: 2)
    end

    @photovoltaics = @home.photovoltaics
    @overview_energy_data = overview_energy_data(@photovoltaics)
    @overview_financial_data = overview_financial_data(@photovoltaics)
  end

  def new
    @home_new = Home.new
  end

  def create
    @home_new = Home.new(home_params)

    if params[:home][:file].present?
      @home_new.handle_uploaded_csv(params[:home][:file])
    else
      (1..12).each do |month|
        @home_new.home_consumption_months[month - 1] = params[:home][:home_consumption_months]["#{month}"].to_i
      end
    end

    @home_new.price_consumption_calculation

    if @home_new.save
      redirect_to homes_path, alert: "Le projet est créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @home = Home.find(params[:id])
  end

  def update
    @home = Home.find(params[:id])
    @home.update(home_params)

    if params[:home][:file].present?
      @home.handle_uploaded_csv(params[:home][:file])
    else
      (1..12).each do |month|
        @home.home_consumption_months[month - 1] = params[:home][:home_consumption_months]["#{month}"].to_f
      end
    end

    @home.price_consumption_calculation

    @home.save
    redirect_to home_path(@home), alert: "Projet actualisé!"
  end

  def destroy
    @home = Home.find(params[:id])
    @home.destroy
    redirect_to homes_path, status: :see_other
  end

  private

  def home_params
    params.require(:home).permit(:name, :address, :buy_price_electricity, :sale_price_electricity)
  end

  def overview_energy_data(photovoltaics)
    power = []
    panel_number =[]
    overview_production = []
    overview_self_consumption = []
    overview_back_energy = []
    photovoltaics.each do |photovoltaic|
      power << photovoltaic.power
      panel_number << photovoltaic.panel_number
      overview_production << photovoltaic.production_months.sum.to_i
      overview_self_consumption << photovoltaic.self_consumption_months.sum.to_i
      overview_back_energy << photovoltaic.back_energy_months.sum.to_i
    end
    return [power, panel_number, overview_production, overview_self_consumption, overview_back_energy].transpose.sort_by(&:first).transpose
  end

  def overview_financial_data(photovoltaics)
    power = []
    investment = []
    roi = []
    profit = []
    performance = []
    panel_number = []
    photovoltaics.each do |photovoltaic|
      power << photovoltaic.power
      investment << photovoltaic.investment
      roi << photovoltaic.roi
      profit << photovoltaic.profit
      performance << photovoltaic.global_performance
      panel_number << photovoltaic.panel_number
    end
    return [power, investment, roi, profit, performance, panel_number].transpose.sort_by(&:first).transpose
  end

end
