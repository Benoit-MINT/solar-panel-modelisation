class HomesController < ApplicationController
  def index
    @homes = Home.all
  end

  def show

  end

end
