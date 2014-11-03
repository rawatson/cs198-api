require "test_helper"

describe Enrollment do
  let(:student_enrollment) do
    Enrollment.new(
      person: people(:student_1),
      course: courses(:cs106a_term_1),
      position: 'student'
    )
  end

  let(:lecturer_enrollment) do
    Enrollment.new(
      person: people(:staff_1),
      course: courses(:cs106a_term_1),
      position: 'lecturer'
    )
  end

  it "must be valid" do
    student_enrollment.must_be :valid?
    student_enrollment.seniority.must_equal 0

    lecturer_enrollment.must_be :valid?
    lecturer_enrollment.seniority.must_equal 2
  end

  describe :position= do
    it "rejects invalid positions" do
      student_enrollment.position = "meow"
      student_enrollment.wont_be :valid?
      student_enrollment.errors.messages[:position].must_include \
        "is not included in the list"
    end

    it "accepts valid positions" do
      Enrollment.positions.each do |t|
        e = Enrollment.new(
          person: people(:staff_1),
          course: courses(:cs106a_term_1),
          position: t
        )

        e.must_be :valid?
        e.position.must_equal t
      end
    end
  end
end
