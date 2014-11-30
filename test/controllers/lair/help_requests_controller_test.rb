require "test_helper"

describe Lair::HelpRequestsController do
  describe :index do
    it "must respond with open requests in sorted order" do
      get :index, format: :json
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |r| r[:open].must_equal true }
      sorted = data.sort do |a, b|
        DateTime.parse(a[:created_at]) <=> DateTime.parse(b[:created_at])
      end
      data.must_equal sorted

      data.each_index do |r_index|
        data[r_index][:position].must_equal r_index
      end
    end
  end

  describe :create do
    it "must create new requests properly" do
      student_id = people(:student_3).id
      course_id = courses(:cs106a_term_2).id
      description = "I broked it"
      location = "42"
      post :create, format: :json,
                    course_id: course_id,
                    person_id: student_id,
                    description: description,
                    location: location
      assert_response :created
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:person][:id].must_equal student_id
      data[:course][:id].must_equal course_id
      data[:description].must_equal description
      data[:location].must_equal location
    end

    # NOTE: this implies a student can make help requests simultaneously for different classes.
    it "must not allow multiple open requests from one enrollment" do
      student_id = people(:student_2).id
      course_id = courses(:cs106a_term_2).id
      description = "I broked it"
      location = "33"
      post :create, format: :json,
                    course_id: course_id,
                    person_id: student_id,
                    description: description,
                    location: location
      assert_response :bad_request

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Validation error"
      data[:details][:errors].must_include \
        "Enrollment only one open help request per enrollment is allowed"
    end
  end

  describe :destroy do
    it "must not delete nonexistent requests" do
      delete :destroy, format: :json, id: "not real"
      assert_response :not_found
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Help request not found"
    end

    it "must not close requests that do not have any assignments" do
      r = help_requests :cs106a_term_2_student_4_help_unassigned
      delete :destroy, format: :json, id: r.id, reason: "resolved"
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Cannot close a request without first assigning it to a helper"
    end

    it "must require a reason" do
      r = help_requests :cs106a_term_2_student_2_help
      delete :destroy, format: :json, id: r.id
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:message].must_equal "Missing required parameter(s)"
      data[:details][:missing].must_equal "reason"
    end

    it "must fail on an invalid reason" do
      r = help_requests :cs106a_term_2_student_2_help
      delete :destroy, format: :json, id: r.id, reason: "invalid reason"
      assert_response :bad_request
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data[:message].must_equal "Validation error"
      data[:details][:errors][:assignment].must_include \
        'Close status must be one of ["resolved", "reassigned", "left"]'

      req = HelpRequest.find r.id
      req.open.must_equal true
      req.helper_assignments.select do |a|
        HelperAssignment.close_status_resolves a.close_status
      end.length.must_equal 0
    end

    it "must set open to false and close the assignment" do
      r = help_requests(:cs106a_term_2_student_2_help)

      delete :destroy, format: :json, id: r.id, reason: "resolved"
      assert_response :no_content
      @response.body.length.must_equal 0

      # check integrity of result
      req = HelpRequest.find r.id
      req.open.must_equal false
      req.current_assignment.must_equal nil
      req.helper_assignments.each { |a| a.close_status.wont_be :nil? }
      req.helper_assignments.select { |a| a.close_status == "resolved" }.length.must_equal 1
      req.helper_assignments.select do |a|
        HelperAssignment.close_status_resolves a.close_status
      end.length.must_equal 1
    end

    it "must be idempotent with already deleted requests" do
      HelpRequest.where(open: false).each do |r|
        delete :destroy, format: :json, id: r.id
        assert_response :no_content
        @response.body.length.must_equal 0

        # check integrity of result
        req = HelpRequest.find r.id
        req.open.must_equal false
        req.current_assignment.must_equal nil
        req.helper_assignments.each { |a| a.close_status.wont_be :nil? }
        req.helper_assignments.select do |a|
          HelperAssignment.close_status_resolves a.close_status
        end.length.must_equal 1
      end
    end
  end

  describe :show do
    it "must find open and closed requests" do
      help_requests.each do |r|
        get :show, id: r.id
        assert_response :ok

        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:id].must_equal r.id
        data[:open].must_equal r.open
      end
    end

    it "must not find nonexistent requests" do
      get :show, id: "not real id"
      assert_response :not_found

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Help request not found"
    end
  end
end
