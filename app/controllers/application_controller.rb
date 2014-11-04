class ApplicationController < ActionController::API
  before_action :convert_boolean_params

  private

  def convert_boolean_params
    params.map do |k, v|
      case v
      when "true"
        params[k] = true
      when "false"
        params[k] = false
      end
    end
  end
end
