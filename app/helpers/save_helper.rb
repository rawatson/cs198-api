# Helpers for saving models.
module SaveHelper
  include Errors
  def save_multiple(instances)
    instances.values.each { |i| i.save validate: false }
    return unless instances.values.map(&:valid?).include? false
    fail CS198::RecordsNotValid.new instances
  end
end
