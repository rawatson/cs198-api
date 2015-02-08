# Helpers for saving models.
module SaveHelper
  include Errors
  def save_multiple(records)
    ActiveRecord::Base.transaction do
      if records.is_a? Hash
        records.each { |_, i| i.save validate: false }
        return unless records.map { |_, i| i.valid? }.include? false
        records = records.reject { |_, i| i.valid? }
      elsif records.is_a? Array
        records.each { |i| i.save validate: false }
        return unless records.map(&:valid?).include? false
        records = records.reject(&:valid?)
      else
        fail "records must be a collection of records"
      end

      fail CS198::RecordsNotValid.new records
    end
  end
end
