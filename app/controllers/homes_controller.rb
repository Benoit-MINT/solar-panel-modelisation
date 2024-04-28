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

    price_consumption_calculation(@home_new)

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
    price_consumption_calculation(@home)
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

  def handle_uploaded_csv(home, file)
    linky_data = []
    CSV.foreach(file, encoding: 'utf-8') do |row|
      linky_data << row
    end
    filtered_data = linky_data.select { |row| row[0]&.start_with?(/^\d/) }
    filtered_data.map! { |row| row[0].split(';').slice(0, 2) }
    filtered_data.select! { |row| row[0].include?("2023") }
    home.home_consumption_months = filtered_data.map { |row| row[1].to_i }.reverse
  end

  def price_consumption_calculation(home)
    (0..11).each do |month|
      home.price_consumption_months[month] = (home.home_consumption_months[month] * home.buy_price_electricity).round(2)
    end
  end
end
