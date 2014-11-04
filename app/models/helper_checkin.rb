class HelperCheckin < ActiveRecord::Base
  belongs_to :person

  validates :person, presence: true
  validate :person_must_be_staff

  def person_must_be_staff
    errors.add :person, "person must be staff to be a helper" unless person.staff
  end
end
