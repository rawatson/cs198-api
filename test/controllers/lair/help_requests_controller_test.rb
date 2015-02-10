require "test_helper"

describe Lair::HelpRequestsController do
  describe :index do
    it "must respond with open/closed requests in sorted order" do
      [nil, false, true].each do |open|
        opts = { format: :json }
        opts[:open] = open unless open.nil?

        get :index, opts
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]

        data.must_be_instance_of Array # list of people
        data.length.must_be :>, 0

        if open.nil?
          data.each { |r| r[:open].must_equal true }
        else
          data.each { |r| r[:open].must_equal open }
        end

        sorted = data.sort do |a, b|
          DateTime.parse(a[:created_at]) <=> DateTime.parse(b[:created_at])
        end
        data.must_equal sorted

        if open || open.nil?
          data.each_index do |r_index|
            data[r_index][:position].must_equal r_index
          end
        else
          data.each { |r| r[:position].must_be_nil }
        end
      end
    end

    it "must filter by since timestamp" do
      timestamp = "29 May 2014"
      get :index, format: :json, open: false, since: timestamp
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data.length.must_be :>, 0

      ids = data.map { |r| r[:id] }
      ids.wont_include help_requests(:cs106a_term_2_student_3_help_closed).id
      ids.must_include help_requests(:cs106a_term_1_student_1_help_closed).id

      data.each do |req|
        DateTime.parse(req[:updated_at]).must_be :>, DateTime.parse(timestamp)
      end
    end

    it "must sort properly with since timestamp" do
      get :index, format: :json, open: false, since: "1 May 2013"
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data.length.must_be :>, 0
      sorted = data.sort do |a, b|
        DateTime.parse(a[:created_at]) <=> DateTime.parse(b[:created_at])
      end
      data.must_equal sorted
    end

    it "must count results correctly" do
      [{ opts: { open: false }, expected: 2 },
       { opts: { open: false, since: "1 May 2013" }, expected: 2 },
       { opts: { open: false, since: "29 May 2014" }, expected: 1 },
       { opts: { open: true }, expected: 3 }
      ].each do |test_case|
        opts = test_case[:opts].merge format: :json, count: true
        get :index, opts
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:count].must_equal test_case[:expected]
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

      data[:message].must_equal "Multi-record validation error"
      data[:details][:records][:assignment][:errors].must_include \
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

  describe :current_assignment do
    it "gets correct assignments" do
      HelpRequest.all.each do |req|
        get :current_assignment, format: :json, help_request_id: req.id
        data = JSON.parse(@response.body, symbolize_names: true)[:data]

        if req.current_assignment.nil?
          assert_response :not_found
          data[:message].must_equal "No helper currently assigned"
        else
          assert_response :ok
          data[:id].must_equal req.current_assignment.id
          data[:help_request][:id].must_equal req.id
        end
      end
    end
  end
end
