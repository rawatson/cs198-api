class Person < ActiveRecord::Base
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_many :helper_checkins
  has_many :help_requests, through: :enrollments

  @citizen_types = ['US Citizen', 'Permanent Resident', 'International']

  validates :suid, uniqueness: true, allow_nil: true
  validates :sunet_id, uniqueness: true
  validates :citizen_status, inclusion: { in: @citizen_types }, allow_nil: true
  validates :email, email: true

  def self.find_by_id_flexible(id)
    p = find_by id: id
    p = find_by sunet_id: id if p.nil?
    p
  end

  def courses_taking
    enrollments.where(position: "student").map(&:course)
  end

  def courses_staffing
    enrollments.where.not(position: "student").map(&:course)
  end
end
