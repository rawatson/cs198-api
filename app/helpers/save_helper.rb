# Helpers for saving models.
module SaveHelper
  include Errors
  def save_multiple(instances)
    ActiveRecord::Base.transaction do
      instances.values.each { |i| i.save validate: false }
      return unless instances.values.map(&:valid?).include? false
      fail CS198::RecordsNotValid.new instances
    end
  end
end
