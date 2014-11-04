require "test_helper"

describe HelperCheckin do
  let(:helper_checkin) do
    HelperCheckin.new(person: people(:staff_1))
  end

  it "must be valid" do
    helper_checkin.must_be :valid?
    helper_checkin.checked_out.must_equal false
  end

  it "must reject students" do
    test_cases = [
      { person: people(:student_1), error: "person must be staff to be a helper" },
      { person: people(:staff_3), error: "person must be active to be a helper" }
    ]

    test_cases.each do |t|
      h = HelperCheckin.new(person: t[:person])
      h.wont_be :valid?
      h.errors.messages[:person].must_include t[:error]
    end
  end
end
