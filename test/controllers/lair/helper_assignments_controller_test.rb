require "test_helper"

describe Lair::HelperAssignmentsController do
  describe :index do
    it "should by default only get active assignments" do
      get :index, format: :json
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.length.must_be :>, 0
      data.each { |a| a[:close_status].must_be :nil? }
    end

    it "should allow specifying active=true" do
      get :index, format: :json, active: true
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.length.must_be :>, 0
      data.each { |a| a[:close_status].must_be :nil? }
    end

    it "should allow getting all assignments with active=false" do
      get :index, format: :json, active: false
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.length.must_be :>, 0
      data.select { |a| a[:close_status].nil? }.length.must_be :>, 0
      data.select { |a| !a[:close_status].nil? }.length.must_be :>, 0
    end

    it "should search by help request" do
      test_occurred = false
      HelpRequest.all.each do |req|
        get :index, format: :json, help_request_id: req.id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]

        test_occurred = true if data.length > 0
        data.each { |a| a[:help_request][:id].must_equal req.id }
        num_closed = data.select { |a| !a[:close_status].nil? }.length
        num_open = data.select { |a| a[:close_status].nil? }.length

        num_open.must_be :<=, 1 if req.open
        num_closed.must_be :>, 0 unless req.open
      end

      test_occurred.must_equal true
    end

    it "should search by helper" do
      test_occurred = false
      HelperCheckin.all.each do |helper|
        get :index, format: :json, helper_id: helper.id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]

        test_occurred = true if data.length > 0
        data.each { |a| a[:helper][:id].must_equal helper.id }
      end

      test_occurred.must_equal true
    end
  end

  describe :create do
    it "should require the correct parameters" do
      req = help_requests :cs106a_term_2_student_4_help_unassigned
      helper = helper_checkins :staff_6_checkin
      possible_missing = %w(helper_id help_request_id)

      validate_response = lambda do |data|
        data[:message].must_equal "Missing required parameter(s)"
        possible_missing.must_include data[:details][:missing]
        possible_missing.sort.must_equal data[:details][:required].sort
      end

      options = [{}, { help_request_id: req.id }, { helper_id: helper.id }]
      options.each do |opts|
        opts[:format] = :json
        post :create, opts
        assert_response :bad_request
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        validate_response[data]
      end
    end

    it "should deny more than one assignment for a helper" do
      req = help_requests :cs106a_term_2_student_4_help_unassigned
      helper = helper_checkins :staff_5_checkin
      post :create, format: :json, helper_id: helper.id, help_request_id: req.id
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:message].must_equal "Validation error"
      data[:details][:errors].must_include "Helper checkin is already assigned"
    end

    it "should deny more than one assignment for a request" do
      req = help_requests :cs106a_term_2_student_2_help
      helper = helper_checkins :staff_6_checkin
      post :create, format: :json, helper_id: helper.id, help_request_id: req.id
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:message].must_equal "Validation error"
      data[:details][:errors].must_include "Help request is already assigned"
    end

    it "should allow a valid assignment" do
      req = help_requests :cs106a_term_2_student_4_help_unassigned
      helper = helper_checkins :staff_6_checkin
      post :create, format: :json, helper_id: helper.id, help_request_id: req.id

      assert_response :created
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:help_request][:id].must_equal req.id
      data[:helper][:id].must_equal helper.id
    end
  end

  describe :show do
    it "should show assignments by id properly" do
      HelperAssignment.count.must_be :>, 0
      HelperAssignment.all.each do |a|
        get :show, format: :json, id: a.id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:id].must_equal a.id
      end
    end
  end

  describe :reassign do
    it "should require the correct parameters" do
      old = helper_assignments :staff_5_open_assignment
      new_helper = helper_checkins :staff_6_checkin
      possible_missing = %w(helper_assignment_id new_helper_id)

      validate_response = lambda do |data|
        data[:message].must_equal "Missing required parameter(s)"
        possible_missing.must_include data[:details][:missing]
        possible_missing.sort.must_equal data[:details][:required].sort
      end

      # helper_assignment_id must be present for URL to match route
      options = [{ helper_assignment_id: '' },
                 { helper_assignment_id: old.id },
                 { helper_assignment_id: '', new_helper_id: new_helper.id }]
      options.each do |opts|
        opts[:format] = :json
        post :reassign, opts
        assert_response :bad_request
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        validate_response[data]
      end
    end

    it "should deny reassignment to an already assigned helper" do
      old = helper_assignments :staff_5_open_assignment
      new_helper = helper_checkins :staff_1_checkin # already has a checkin

      post :reassign, format: :json, helper_assignment_id: old.id, new_helper_id: new_helper.id
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Validation error"
      data[:details][:errors][:new_assignment].must_include "Helper checkin is already assigned"

      # check that old assignment is still current
      HelperAssignment.find(old.id).close_status.must_be :nil?
      HelpRequest.find(old.help_request.id).current_assignment.id.must_equal old.id
    end

    it "should create a new assignment and close the old one with status=reassigned" do
      old = helper_assignments :staff_5_open_assignment
      new_helper = helper_checkins :staff_6_checkin # already has a checkin

      post :reassign, format: :json, helper_assignment_id: old.id, new_helper_id: new_helper.id
      assert_response :ok
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:helper][:id].must_equal new_helper.id
      data[:help_request][:id].must_equal old.help_request.id

      # check if old assignment is now reassigned
      old_assignment = HelperAssignment.find(old.id)
      old_assignment.close_status.must_equal "reassigned"
      old_assignment.reassignment_id.must_equal data[:id]
    end
  end
end
