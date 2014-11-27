class HelperCheckin < ActiveRecord::Base
  belongs_to :person
  has_many :helper_assignments

  # person may only be checked into the queue once
  validates :person,
            presence: true,
            uniqueness: {
              conditions: -> { where checked_out: false },
              if: -> (h) { !h.checked_out },
              message: "is already checked in"
            }
  validate :validate_person

  def validate_person
    errors.add :person, "person must be staff to be a helper" unless person.staff
    errors.add :person, "person must be active to be a helper" unless person.active
  end
end
