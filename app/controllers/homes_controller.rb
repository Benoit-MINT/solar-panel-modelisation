class HomesController < ApplicationController
  def index
    @homes = Home.all
  end

  def show

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

  private

  def home_params
    params.require(:home).permit(:address)
  end

end
