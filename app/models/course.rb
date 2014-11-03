class Course < ActiveRecord::Base
  has_many :enrollments
  has_many :people, through: :enrollments
  belongs_to :term
end
