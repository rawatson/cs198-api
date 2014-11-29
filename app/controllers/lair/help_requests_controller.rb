class Lair::HelpRequestsController < ApplicationController
  def index
    @requests = HelpRequest.where(open: true).order(created_at: :asc).includes(:person, :course)
    render :index
  end

  def create
    attributes = helper_create_params(params)
    enrollment = Enrollment.find_by(course_id: params[:course_id], person_id: params[:person_id])

    render status: :not_found, json: { data: {
      message: "Enrollment not found" } } if enrollment.nil?

    attributes[:enrollment] = enrollment
    @request = HelpRequest.new attributes

    if @request.valid?
      @request.save
      render :show, status: :created
    else
      render status: :bad_request, json: { data: {
        message: "Unable to create help request",
        details: { errors: @request.errors.full_messages } } }
    end
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, self.class.creation_params
  end

  def show
    @request = HelpRequest.find(params[:id])
    render :show
  rescue
    render status: :not_found, json: { data: {
      message: "Help request not found" } }
  end

  def update
    fail 'Not implemented'
  end

  def destroy
    @request = HelpRequest.find(params[:id])

    # TODO: update helper assignment as well
    @request.open = false
    @request.save
    head status: :no_content
  rescue
    render status: :not_found, json: { data: {
      message: "Help request not found" } }
  end

  private

  @creation_params = [:course_id, :person_id, :description, :location]
  class << self
    attr_accessor :creation_params
  end

  def helper_create_params(params)
    self.class.creation_params.each do |p|
      params.require(p)
    end

    params.permit(:description, :location)
  end
end
