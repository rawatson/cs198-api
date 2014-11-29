require "test_helper"

describe HelperAssignment do
  let(:helper_assignment) { HelperAssignment.new }

  it "must validate valid assignments" do
    HelperAssignment.all.each { |a| a.must_be :valid? }
  end

  it "must provide correct resolution status for close_status_resolves" do
    %w(resolved left).each do |status|
      HelperAssignment.close_status_resolves(status).must_equal true
    end

    ["reassigned", "fake reason", nil].each do |status|
      HelperAssignment.close_status_resolves(status).must_equal false
    end
  end

  it "must provide valid close statuses" do
    HelperAssignment.close_statuses.sort.must_equal %w(resolved reassigned left).sort
  end

  it "must reject invalid close status" do
    a = helper_assignments :staff_1_closed_assignment
    a.close_status = "fake close status"
    a.wont_be :valid?
    a.errors.messages[:close_status].count do |err|
      err == "must be one of #{HelperAssignment.close_statuses}"
    end.must_equal 1, "Invalid close status did not trigger validation error"
  end

  it "must reject resolving close status on an open request" do
    a = helper_assignments :staff_5_open_assignment
    a.close_status = "resolved"
    a.wont_be :valid?
    a.errors.messages[:help_request].must_include \
      "must be closed to close the assignment without reassigning"
  end

  it "must reject close status without close time" do
    a = helper_assignments :staff_5_open_assignment
    a.close_status = "resolved"
    a.wont_be :valid?
    a.errors.messages[:close_time].must_include "can't be blank"
  end

  it "must reject close time without close status" do
    a = helper_assignments :staff_5_open_assignment
    a.close_time = "3 Jun 2014 7:00PM"
    a.wont_be :valid?
    a.errors.messages[:close_status].must_include "can't be blank"
  end

  it "must reject close time before claim time" do
    a = helper_assignments :staff_5_open_assignment
    a.close_time = "3 Jun 2014 5:00PM"
    a.wont_be :valid?
    a.errors.messages[:close_time].must_include "Close time must occur after claim time"
  end

  it "must reject close_status == reassigned without reassignment" do
    a = helper_assignments :staff_5_open_assignment
    a.close_status = "reassigned"
    a.wont_be :valid?
    a.errors.messages[:close_status].must_include \
      "may not be set to 'reassigned' without specifying reassignment id"
  end

  it "must reject close_status != reassigned with reassignment" do
    a = helper_assignments :staff_5_open_assignment
    a.reassignment = a
    a.wont_be :valid?
    a.errors.messages[:reassignment].must_include \
      "must not be set if close_status is not set to 'reassigned'"

    a.close_status = "resolved"
    a.wont_be :valid?
    a.errors.messages[:reassignment].must_include \
      "must not be set if close_status is not set to 'reassigned'"
  end

  it "must reject assignment on a closed request" do
    req = help_requests :cs106a_term_2_student_3_help_closed
    a = helper_assignments :staff_5_open_assignment
    a.help_request = req

    a.wont_be :valid?
    a.errors.messages[:help_request].must_include "must be open to assign"
  end
end
