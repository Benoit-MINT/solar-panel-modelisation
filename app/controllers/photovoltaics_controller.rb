class PhotovoltaicsController < ApplicationController

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
    if @photovoltaic_new.save
      redirect_to home_path(@home), alert: "L'installation est créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def photovoltaic_params
    params.require(:photovoltaic).permit(:power)
  end
end
