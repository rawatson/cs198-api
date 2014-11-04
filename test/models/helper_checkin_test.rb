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
    h = HelperCheckin.new(person: people(:student_1))
    h.wont_be :valid?
    h.errors.messages[:person].must_include \
      "person must be staff to be a helper"
  end
end
