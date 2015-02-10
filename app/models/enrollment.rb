class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :person
  has_many :help_requests

  # key: position name, value: seniority
  @default_seniorities = {
    student: 0,
    course_helper: 0,
    senior_course_helper: 1,
    section_leader: 1,
    senior_section_leader: 2,
    lecturer: 2,
    coordinator: 2,
    teaching_assistant: 2
  }

  class << self
    def positions
      @default_seniorities.keys.map(&:to_s)
    end

    def default_seniority(p)
      @default_seniorities[p.to_sym]
    end
  end

  validates :position, inclusion: { in: Enrollment.positions.map(&:to_s) }
  validates :seniority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Sets the seniority along with the position
  def position=(p)
    if self.class.positions.include? p.to_s
      self.seniority = self.class.default_seniority p
    end

    super
  end
end
