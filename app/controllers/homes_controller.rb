class HomesController < ApplicationController
  require "csv"

  def index
    @homes = Home.all
    @home_new = Home.new
  end

  def show
    @home = Home.find(params[:id])
    @photovoltaics = @home.photovoltaics
  end

  def new
    @home_new = Home.new
  end

  def create
    @home_new = Home.new(home_params)

    if params[:home][:file].present?
      handle_uploaded_csv(@home_new, params[:home][:file])
    else
      (1..12).each do |month|
        @home_new.home_consumption_months[month - 1] = params[:home][:home_consumption_months]["#{month}"].to_i
      end
    end
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
    (1..12).each do |month|
      @home.home_consumption_months[month - 1] = params[:home][:home_consumption_months]["#{month}"].to_f
    end
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
    params.require(:home).permit(:name, :address)
  end

  def handle_uploaded_csv(home, file)
    linky_data = []
    CSV.foreach(file) do |row|
      linky_data << row[1..-1]
    end
    home.home_consumption_months = linky_data[1].map!(&:to_i)
  end

end
