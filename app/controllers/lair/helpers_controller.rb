class Lair::HelpersController < ApplicationController
  def index
    data = {}

    if params[:inactive]
      data = HelperCheckin.all
    else
      data = HelperCheckin.where(checked_out: false)
    end

    render json: { data: data }
  end

  def create
    fail "Not implemented"
  end

  def shifts
    fail "Not implemented"
  end

  def show
    fail "Not implemented"
  end

  def update
    fail "Not implemented"
  end

  def destroy
    fail "Not implemented"
  end
end
