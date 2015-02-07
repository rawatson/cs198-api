# Helpers for rendering certain responses
module RenderHelper
  def render_missing_params(missing, required)
    render status: :bad_request, json: { data: {
      message: "Missing required parameter(s)",
      details: { missing: missing, required: required } } }
  end

  def render_validation_error(records)
    if records.is_a? ActiveRecord::Base
      render status: :bad_request, json: { data: {
        message: "Validation error",
        details: { errors: records.errors.full_messages } } }
    else
      if records.is_a? Array
        records_errors = records.map { |i| { errors: i.errors.full_messages } }
      elsif records.is_a? Hash
        records_errors = Hash[records.map { |k, v| [k, { errors: v.errors.full_messages }] }]
      else
        fail "render_validation_error must receive a collection of records or a record"
      end

      render status: :bad_request, json: { data: {
        message: "Multi-record validation error",
        details: { records: records_errors } } }
    end
  end
end
