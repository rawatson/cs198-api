class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :person

  # key: position name, value: seniority
  @position_types = {
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
    attr_accessor :position_types
  end

  validates :position, inclusion: { in: @position_types.keys.map(&:to_s) }
  validates :seniority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Sets the seniority along with the position
  def position=(p)
    p = p.to_sym
    if self.class.position_types.key?(p)
      self.seniority = self.class.position_types[p]
      super
    else
      fail "Invalid position type provided: #{p}, #{self.class.position_types}"
    end
  end
end
