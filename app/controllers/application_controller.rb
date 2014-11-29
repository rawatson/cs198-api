class ApplicationController < ActionController::API
  include ParamsHelper
  include Errors

  before_action :convert_boolean_params

  protected

  def render_missing_params(missing, required)
    render status: :bad_request, json: { data: {
      message: "Missing required parameter(s)",
      details: { missing: missing, required: required } } }
  end

  private

  def convert_boolean_params
    self.params = coerce_boolean_strings params unless params.nil?
  end
end
