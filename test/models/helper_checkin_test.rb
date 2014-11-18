require "test_helper"

describe HelperCheckin do
  it "must be valid" do
    h = HelperCheckin.new(person: people(:staff_2))
    h.must_be :valid?
    h.checked_out.must_equal false
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

  it "must not allow multiple active checkins of same person" do
    active = helper_checkins(:staff_1_checkin_incomplete)
    h = HelperCheckin.new(person: active.person)

    h.wont_be :valid?
    h.errors.messages[:person].must_include "is already checked in"
  end

  it "must allow multiple active checkins of different people" do
    h = HelperCheckin.new(person: people(:staff_2))
    h.must_be :valid?
  end

  it "must allow multiple inactive checkins" do
    finished = helper_checkins(:staff_2_checkin_finished)
    h = HelperCheckin.new(person: finished.person)
    h.must_be :valid?
    h.checked_out = true
    h.must_be :valid?

    h2 = HelperCheckin.new(person: people(:staff_1), checked_out: true)
    h2.must_be :valid?

    active = helper_checkins(:staff_1_checkin_incomplete)
    active.checked_out = true
    active.must_be :valid?
  end
end