class ApplicationController < ActionController::API
  include ParamsHelper
  include Errors

  before_action :convert_boolean_params
  before_action :cors_header

  def options
    head status: :ok
  end

  protected

  # To allow requests from whitelisted domains to bypass the Same-Origin Policy
  def cors_header
    headers["Access-Control-Allow-Origin"] = "*" # TODO: read origin header, check if whitelisted
    headers["Access-Control-Allow-Methods"] = "GET,PUT,POST,DELETE"
  end

  def render_missing_params(missing, required)
    render status: :bad_request, json: { data: {
      message: "Missing required parameter(s)",
      details: { missing: missing, required: required } } }
  end

  def render_validation_error(instance)
    render status: :bad_request, json: { data: {
      message: "Validation error",
      details: { errors: instance.errors.full_messages } } }
  end

  private

  def convert_boolean_params
    self.params = coerce_boolean_strings params unless params.nil?
  end
end
