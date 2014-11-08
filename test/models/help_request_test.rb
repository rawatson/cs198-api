require "test_helper"

describe HelpRequest do
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
end
