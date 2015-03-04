class HelperCheckin < ActiveRecord::Base
  belongs_to :person
  has_many :helper_assignments

  def self.find_latest_by_person(person)
    where(person: person).order("created_at").last
  end

  def current_assignment
    helper_assignments.find_by close_status: nil
  end

  # person may only be checked into the queue once
  validates :person,
            presence: true,
            uniqueness: {
              conditions: -> { where checked_out: false },
              if: -> (h) { !h.checked_out },
              message: "is already checked in"
            }
  validate :validate_person
  validate :validate_checked_out

  def validate_checked_out
    return unless checked_out

    open_assignments = helper_assignments.reduce false do |memo, a|
      memo || a.close_status.nil?
    end
    errors.add(:checked_out,
               "may not check out with open assignments") if open_assignments
  end

  def validate_person
    errors.add :person, "person must be staff to be a helper" unless person.staff
    errors.add :person, "person must be active to be a helper" unless person.active
  end
end
