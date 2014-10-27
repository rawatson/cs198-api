class Course < ActiveRecord::Base
  has_many :people, through: :enrollments

  belongs_to :term
end
