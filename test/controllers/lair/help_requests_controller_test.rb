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
      data[:message].must_equal "Unable to create help request"
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

    it "must set open to false" do
      r = help_requests(:cs106a_term_2_student_2_help)

      delete :destroy, format: :json, id: r.id
      assert_response :no_content
      @response.body.length.must_equal 0

      get :show, format: :json, id: r.id
      assert_response :ok
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:id].must_equal r.id
      data[:open].must_equal false
    end

    it "must be idempotent with already deleted requests" do
      r = help_requests(:cs106a_term_2_student_3_help_closed)

      delete :destroy, format: :json, id: r.id
      assert_response :no_content
      @response.body.length.must_equal 0

      get :show, format: :json, id: r.id
      assert_response :ok
      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:id].must_equal r.id
      data[:open].must_equal false
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
