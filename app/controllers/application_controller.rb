class ApplicationController < ActionController::API
  include ParamsHelper

  before_action :convert_boolean_params

  private

  def convert_boolean_params
    self.params = coerce_boolean_strings params unless params.nil?
  end
end
