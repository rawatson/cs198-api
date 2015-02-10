class Course < ActiveRecord::Base
  has_many :enrollments
  has_many :people, through: :enrollments
  has_many :help_requests, through: :enrollments
  belongs_to :term
end
