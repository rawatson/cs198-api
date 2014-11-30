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
    p = Person.find params[:person]

    # idempotent
    @helper = HelperCheckin.includes(:person).find_by(person_id: p, checked_out: false)
    return render :show unless @helper.nil?

    @helper = HelperCheckin.new person: p
    if @helper.valid?
      @helper.save
      render :show, status: :created
    else
      # TODO: handle errors more robustly
      return render status: :forbidden, json: { data: {
        message: "Must be an active staff member to check in as a helper." } }
    end
  rescue
    return render status: :not_found, json: { data: {
      message: "Person not found" } }
  end

  def destroy
    h = HelperCheckin.find(params[:id])

    # If they are already checked out, just don't change the timestamp.
    # Success for idempotency
    unless h.checked_out
      h.check_out_time = DateTime.now
      h.checked_out = true
      h.save
    end

    head :no_content
  rescue ActiveRecord::RecordNotFound
    return render status: :not_found, json: { data: {
      message: "Helper checkin not found." } }
  end

  def show
    @helper = HelperCheckin.includes(:person).find(params[:id])
    render :show
  rescue ActiveRecord::RecordNotFound
    return render status: :not_found, json: { data: {
      message: "Helper checkin not found." } }
  end

  def shifts
    fail "Not implemented"
  end
end
