class HelpRequest < ActiveRecord::Base
  belongs_to :enrollment
  has_one :person, through: :enrollment
  has_one :course, through: :enrollment

  validates :enrollment, uniqueness: {
    conditions: -> { where open: true },
    if: -> (hr) { hr.open },
    message: "only one open help request per enrollment is allowed"
  }, presence: true
  validate :validate_enrollment

  def validate_enrollment
    errors.add(:enrollment, "person must be enrolled as a student " \
                            "to request help") unless enrollment.position == "student"
    # TODO: enforce currently active term
  end
end
