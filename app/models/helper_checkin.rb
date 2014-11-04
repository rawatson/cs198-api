class HelperCheckin < ActiveRecord::Base
  belongs_to :person

  validates :person, presence: true
  validate :validate_person

  def validate_person
    errors.add :person, "person must be staff to be a helper" unless person.staff
    errors.add :person, "person must be active to be a helper" unless person.active
  end
end
