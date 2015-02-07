# Helpers for rendering certain responses
module RenderHelper
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
end
