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

  describe :current_assignment do
    it "properly gets current open assignment" do
      test_cases = [
        { helper: helper_checkins(:staff_2_checkin_finished), expected: nil },
        { helper: helper_checkins(:staff_6_checkin), expected: nil },
        { helper: helper_checkins(:staff_1_checkin),
          expected: helper_assignments(:staff_1_open_reassigned_assignment) },
        { helper: helper_checkins(:staff_5_checkin),
          expected: helper_assignments(:staff_5_open_assignment) }
      ]

      test_cases.each do |test_case|
        test_case[:helper].current_assignment.must_equal test_case[:expected]
      end
    end
  end

  describe :find_latest_by_person do
    it "finds the latest element by person" do
      person = people :staff_2
      new_checkin = HelperCheckin.new person: person
      new_checkin.must_be :valid?
      new_checkin.save

      retrieved = HelperCheckin.find_latest_by_person person
      retrieved.id.must_equal new_checkin.id

      new_checkin.checked_out = true
      new_checkin.save

      retrieved = HelperCheckin.find_latest_by_person person
      retrieved.id.must_equal new_checkin.id

      old_checkin = new_checkin
      new_checkin = HelperCheckin.new person: person
      new_checkin.save
      old_checkin.id.wont_equal new_checkin.id

      retrieved = HelperCheckin.find_latest_by_person person
      retrieved.id.must_equal new_checkin.id
    end

    it "doesn't fail if person doesn't have any checkins" do
      retrieved = HelperCheckin.find_latest_by_person people(:student_1)
      retrieved.must_be_nil
    end
  end
end
