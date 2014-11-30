require "test_helper"
require "json"

describe Lair::HelpersController do
  describe :index do
    it "must work without inactive flag" do
      get :index, format: :json
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |p| p[:checked_out].wont_be_nil } # TODO: improve HelperCheckin format check
    end

    it "must work with inactive=false" do
      get :index, format: :json
      assert_response :success
      response_without_inactive = @response.body

      get :index, format: :json, inactive: "false"
      assert_response :success
      response_without_inactive.must_equal @response.body

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |p| p[:checked_out].wont_be_nil } # TODO: improve HelperCheckin format check
    end

    it "must work with inactive=true" do
      get :index, format: :json
      assert_response :success
      data_without_inactive = JSON.parse(@response.body, symbolize_names: true)[:data]

      get :index, format: :json, inactive: "true"
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      # inactive=true returns a superset of inactive=false
      data_without_inactive.length.must_be :<, data.length
      data_without_inactive.each { |e| data.must_include e }

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |p| p[:checked_out].wont_be_nil } # TODO: improve HelperCheckin format check
    end
  end

  describe :create do
    it "must 404 on nonexistent person" do
      post :create, format: :json, person: "hello"

      assert_response :missing

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Person not found"
    end

    it "must 201 on a new checkin" do
      post :create, format: :json, person: people(:staff_4).id
      assert_response :created

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:person][:id].must_equal people(:staff_4).id
    end

    it "must 200 on an already existent checkin" do
      post :create, format: :json, person: people(:staff_1).id
      assert_response :ok

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:person][:id].must_equal people(:staff_1).id
    end

    it "must 403 on a non-staff person" do
      post :create, format: :json, person: people(:student_1).id
      assert_response :forbidden

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Must be an active staff member to check in as a helper."
    end
  end

  describe :delete do
    it "404's on nonexistent checkins" do
      delete :destroy, format: :json, id: "hello"
      assert_response :missing

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Helper checkin not found."
    end

    it "204's with no content on success" do
      delete :destroy, format: :json, id: helper_checkins(:staff_1_checkin).id
      assert_response :no_content

      @response.body.length.must_equal 0
    end

    it "204's with no content on already checked out checkins" do
      delete :destroy, format: :json, id: helper_checkins(:staff_2_checkin_finished).id
      assert_response :no_content

      @response.body.length.must_equal 0
    end
  end

  describe :show do
    it "404's on nonexistent checkins" do
      get :show, format: :json, id: "hello"
      assert_response :missing

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:message].must_equal "Helper checkin not found."
    end

    it "200's on existent checkins" do
      helper_checkins.each do |h|
        get :show, format: :json, id: h.id
        assert_response :ok

        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:person][:id].must_equal h.person_id
        data[:checked_out].must_equal h.checked_out
      end
    end
  end

  describe :current_assignment do
    it "gets correct assignments" do
      HelperCheckin.all.each do |h|
        get :current_assignment, format: :json, id: h.id
        data = JSON.parse(@response.body, symbolize_names: true)[:data]

        if h.current_assignment.nil?
          assert_response :not_found
          data[:message].must_equal "Not currently assigned to a help request"
        else
          assert_response :ok
          data[:id].must_equal h.current_assignment.id
          data[:helper][:id].must_equal h.id
        end
      end
    end
  end
end
