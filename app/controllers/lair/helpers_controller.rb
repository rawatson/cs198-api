class Lair::HelpersController < ApplicationController
  def index
    if params[:inactive]
      @helpers = HelperCheckin.all.includes(:person)
    else
      @helpers = HelperCheckin.where(checked_out: false).includes(:person)
    end

    render :index
  end

  def create
    begin
      p = Person.find params[:person]
    rescue
      return render status: :not_found, json: { message: "Person not found" }
    end

    # idempotent
    @helper = HelperCheckin.includes(:person).find_by(person_id: p, checked_out: false)
    return render :show unless @helper.nil?

    @helper = HelperCheckin.new person: p
    if @helper.valid?
      @helper.save
      render :show, status: :created
    else
      # TODO: handle errors more robustly
      return render status: :forbidden,
                    json: { message: "Must be an active staff member to check in as a helper." }
    end
  end

  def destroy
    begin
      h = HelperCheckin.find(params[:id])
    rescue
      return render status: :not_found, json: { message: "Helper checkin not found." }
    end

    # If they are already checked out, just don't change the timestamp.
    # Success for idempotency
    unless h.checked_out
      h.check_out_time = DateTime.now
      h.checked_out = true
      h.save
    end

    head :no_content
  end

  def show
    begin
      @helper = HelperCheckin.includes(:person).find(params[:id])
    rescue
      return render status: :not_found, json: { message: "Helper checkin not found." }
    end

    render :show
  end

  def shifts
    fail "Not implemented"
  end
end
