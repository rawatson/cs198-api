class Lair::HelpRequestsController < ApplicationController
  def index
    open = params[:open].nil? ? true : params[:open]
    since = params[:since]
    count = params[:count].nil? ? false : params[:count]

    if since.nil?
      @requests = HelpRequest.where(open: open).order(created_at: :asc).includes(:person, :course)
      return render json: { data: { count: @requests.count } } if count
    else
      @requests = HelpRequest.where(
        "open = :open AND updated_at > :since", open: open, since: DateTime.parse(since)
      ).order(created_at: :desc)
      return render json: { data: { count: @requests.count } } if count
      @requests = @requests.includes(:person, :course).reverse
    end

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
      render_validation_error @request
    end
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, self.class.creation_params
  end

  def show
    @request = HelpRequest.find(params[:id])
    render :show
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Help request not found" } }
  end

  def update
    fail 'Not implemented'
  end

  def destroy
    @request = HelpRequest.find(params[:id])
    return head status: :no_content unless @request.open

    assignment = @request.current_assignment
    return render status: :bad_request, json: { data: {
      message: "Cannot close a request without first assigning it to a helper"
    } } if assignment.nil?

    params.require :reason

    @request.open = false
    assignment.close_status = params[:reason]
    assignment.close_time = DateTime.now

    save_multiple(assignment: assignment, request: @request)
    head status: :no_content
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Help request not found" } }
  rescue CS198::RecordsNotValid => e
    render_validation_error e.records
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, self.class.closing_params
  end

  def current_assignment
    request = HelpRequest.find params[:help_request_id]
    @assignment = request.current_assignment

    return render status: :not_found, json: { data: {
      message: "No helper currently assigned" } } if @assignment.nil?
    render "lair/helper_assignments/show"
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Help request not found." } }
  end

  private

  @creation_params = [:course_id, :person_id, :description, :location]
  @closing_params = [:reason]
  class << self
    attr_reader :creation_params
    attr_reader :closing_params
  end

  def helper_create_params(params)
    self.class.creation_params.each do |p|
      params.require(p)
    end

    params.permit(:description, :location)
  end
end
