require "test_helper"

describe HelpRequest do
  it "allows valid requests" do
    HelpRequest.all.each { |hr| hr.must_be :valid? }
  end

  it "allows help requests for students" do
    hr = HelpRequest.new(enrollment: enrollments(:cs106a_term_2_student_3),
                         description: "Is broked",
                         location: "20")
    hr.must_be :valid?
  end

  it "disallows help requests for non-students" do
    [enrollments(:cs106a_term_2_sl),
     enrollments(:cs106a_term_2_lecturer)].each do |e|
      hr = HelpRequest.new(enrollment: e,
                           description: "Is broked",
                           location: "20")
      hr.wont_be :valid?
      hr.errors.messages[:enrollment].must_include \
        "person must be enrolled as a student to request help"
    end
  end

  it "only allows one help request per enrollment" do
    hr = help_requests(:cs106a_term_2_student_2_help)
    new_hr = HelpRequest.new(enrollment: hr.enrollment,
                             description: "Is broked",
                             location: "14")
    new_hr.wont_be :valid?
    new_hr.errors.messages[:enrollment].must_include \
      "only one open help request per enrollment is allowed"
  end

  it "rejects checked_out=false if no closed helper assignment exists" do
    reqs = HelpRequest.where open: true
    reqs.length.must_be :>, 0
    reqs.each do |hr|
      hr.must_be :valid?
      hr.open = false
      puts "ID: #{hr.id}" if hr.valid?
      hr.wont_be :valid?

      hr.errors.messages[:open].must_include \
        "can only be closed if a closed helper assignment exists"
    end
  end

  describe :current_assignment do
    it "properly gets current open assignment" do
      test_cases = [
        { request: help_requests(:cs106a_term_1_student_1_help_closed), expected: nil },
        { request: help_requests(:cs106a_term_2_student_2_help),
          expected: helper_assignments(:staff_1_open_reassigned_assignment) },
        { request: help_requests(:cs106a_term_1_student_1_help),
          expected: helper_assignments(:staff_5_open_assignment) }
      ]

      test_cases.each do |test_case|
        test_case[:request].current_assignment.must_equal test_case[:expected]
      end
    end
  end
end
