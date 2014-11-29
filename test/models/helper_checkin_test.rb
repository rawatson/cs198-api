require "test_helper"

describe HelperCheckin do
  it "must accept valid checkins" do
    HelperCheckin.count.must_be :>, 0
    HelperCheckin.all.each { |h| h.must_be :valid? }
  end

  it "must set checked_out to false by default" do
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
    active = helper_checkins(:staff_1_checkin)
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

    # staff 1 is already checked in
    h2 = HelperCheckin.new(person: people(:staff_1), checked_out: true)
    h2.must_be :valid?
  end

  it "must reject setting checked_out=true if open requests outstanding" do
    active = helper_checkins(:staff_1_checkin)
    active.checked_out = true
    active.wont_be :valid?
    active.errors.messages[:checked_out].must_include "may not check out with open assignments"
  end
end
