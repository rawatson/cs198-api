class HelpRequest < ActiveRecord::Base
  belongs_to :enrollment
  has_one :person, through: :enrollments
  has_one :course, through: :enrollments
end
