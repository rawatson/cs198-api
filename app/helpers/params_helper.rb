# Helpers for working with parameters in Controller actions.
#
# NOTE: as a policy, don't change the params hash directly; return modified copies only.
# NOTE: The Rails params hash is not a raw Hash, so rather than returning a newly initialized Hash,
# clone the existing one and edit the copy.
module ParamsHelper
  # Replace "true" and "false" values with boolean true and false values.
  def coerce_boolean_strings(params)
    params = params.clone
    params.each do |k, v|
      case v
      when "true"
        params[k] = true
      when "false"
        params[k] = false
      end
    end
    params
  end
end
