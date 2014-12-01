class Lair::HelperAssignmentsController < ApplicationController
  def index
    options = {}
    options[:help_request_id] = params[:help_request_id] unless params[:help_request_id].nil?
    options[:helper_checkin_id] = params[:helper_id] unless params[:helper_id].nil?

    if (params[:active].nil? && options.empty?) || params[:active] == true
      options[:close_status] = nil
    end

    @assignments = HelperAssignment.where(options).includes(:helper_checkin, :help_request,
                                                            :student, :helper)
    render :index
  end

  def show
    params.require :id
    @assignment = HelperAssignment.find params[:id]
    render :show
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Helper assignment not found" } }
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, [:id]
  end

  def create
    p = enforce_creation_params params
    @assignment = HelperAssignment.new helper_checkin_id: p[:helper_id],
                                       help_request_id: p[:help_request_id],
                                       claim_time: DateTime.now
    @assignment.save!
    render :show, status: :created
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, self.class.creation_params
  rescue ActiveRecord::RecordInvalid
    render_validation_error @assignment
  end

  def reassign
    if params[:helper_assignment_id].nil? && !params[:help_request_id].nil?
      request = HelpRequest.find params[:help_request_id]
      fail ActiveRecord::RecordNotFound if request.current_assignment.nil?
      params[:helper_assignment_id] = request.current_assignment.id
    end

    p = enforce_reassignment_params params
    old = HelperAssignment.find p[:helper_assignment_id]
    @assignment = reassign_request old, p[:new_helper_id]
    render :show
  rescue CS198::RecordsNotValid => e
    render status: :bad_request, json: { data: {
      message: "Validation error",
      details: { errors: {
        original_assignment: e.records[:original_assignment].errors.full_messages,
        new_assignment: e.records[:new_assignment].errors.full_messages } }
    } }
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Helper assignment not found" } }
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, self.class.reassignment_params
  end

  private

  @creation_params = [:help_request_id, :helper_id]
  @reassignment_params = [:helper_assignment_id, :new_helper_id]
  class << self
    attr_reader :creation_params
    attr_reader :reassignment_params
  end

  def enforce_creation_params(params)
    self.class.creation_params.each do |p|
      params.require p
    end

    params.permit self.class.creation_params
  end

  def enforce_reassignment_params(params)
    self.class.reassignment_params.each do |p|
      params.require p
    end

    params.permit self.class.reassignment_params
  end

  def reassign_request(old_assignment, new_helper_id)
    new_assignment = HelperAssignment.new helper_checkin_id: new_helper_id,
                                          help_request: old_assignment.help_request,
                                          claim_time: DateTime.now
    old_assignment.close_time = new_assignment.claim_time
    old_assignment.close_status = "reassigned"
    old_assignment.reassignment = new_assignment

    old_assignment.transaction do
      new_assignment.save validate: false
      old_assignment.save validate: false

      return new_assignment if new_assignment.valid? && old_assignment.valid?
      fail CS198::RecordsNotValid.new original_assignment: old_assignment,
                                      new_assignment: new_assignment
    end

    new_assignment
  end
end
