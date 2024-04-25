class HomesController < ApplicationController
  def index
    @homes = Home.all
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
    (1..12).each do |month|
      @home_new.home_consumption_months[month - 1] = params[:home][:home_consumption_months]["#{month}"].to_f
    end
    if @home_new.save
      redirect_to homes_path, alert: "Le projet est créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @home = Home.find(params[:id])
    @home.destroy
    redirect_to homes_path, status: :see_other
  end

  private

  def home_params
    params.require(:home).permit(:address)
  end

end
