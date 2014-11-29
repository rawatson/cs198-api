class HelpRequest < ActiveRecord::Base
  belongs_to :enrollment
  has_one :person, through: :enrollment
  has_one :course, through: :enrollment
  has_many :helper_assignments

  validates :enrollment, uniqueness: {
    conditions: -> { where open: true },
    if: -> (hr) { hr.open },
    message: "only one open help request per enrollment is allowed"
  }, presence: true
  validate :validate_enrollment
  validate :validate_closed

  def validate_closed
    return if open

    closing_assignment = helper_assignments.select do |a|
      HelperAssignment.close_status_resolves a.close_status
    end.length == 0

    errors.add :open, "can only be closed if a closed helper "\
      "assignment exists" if closing_assignment
  end

  def position
    HelpRequest.where(
      "open = :open AND created_at < :time", open: true, time: created_at
    ).count
  end

  def validate_enrollment
    errors.add(:enrollment, "person must be enrolled as a student " \
                            "to request help") unless enrollment.position == "student"
    # TODO: enforce currently active term
  end
end
