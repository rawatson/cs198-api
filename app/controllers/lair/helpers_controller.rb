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
    begin
      p = Person.find params[:person]
    rescue
      return render status: :not_found, json: { message: "Person not found" }
    end

    # idempotent
    checked_in = HelperCheckin.where(person_id: p, checked_out: false)
    return render status: :ok, json: { data: checked_in.first } if checked_in.exists?

    h = HelperCheckin.new person: p
    if h.valid?
      h.save
      return render status: :created, json: { data: h }
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
      h = HelperCheckin.find(params[:id])
    rescue
      return render status: :not_found, json: { message: "Helper checkin not found." }
    end

    render json: { data: h }
  end

  def shifts
    fail "Not implemented"
  end
end
