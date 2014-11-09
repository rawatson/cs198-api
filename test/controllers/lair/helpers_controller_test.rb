require "test_helper"
require "json"

describe Lair::HelpersController do
  describe :index do
    it "must work without inactive flag" do
      get :index
      assert_response :success
      data = JSON.parse(@response.body, symbolize_names: true)[:data]

      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |p| p[:checked_out].wont_be_nil } # TODO: improve HelperCheckin format check
    end

    it "must work with inactive=false" do
      get :index
      assert_response :success
      response_without_inactive = @response.body

      get :index, inactive: "false"
      assert_response :success
      response_without_inactive.must_equal @response.body

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data.must_be_instance_of Array # list of people
      data.length.must_be :>, 0
      data.each { |p| p[:checked_out].wont_be_nil } # TODO: improve HelperCheckin format check
    end

    it "must work with inactive=true" do
      get :index
      assert_response :success
      data_without_inactive = JSON.parse(@response.body, symbolize_names: true)[:data]

      get :index, inactive: "true"
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
      post :create, person: "hello"

      assert_response :missing

      message = JSON.parse(@response.body, symbolize_names: true)[:message]
      message.must_equal "Person not found"
    end

    it "must 201 on a new checkin" do
      post :create, person: people(:staff_4).id
      assert_response :created

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:person_id].must_equal people(:staff_4).id
    end

    it "must 200 on an already existent checkin" do
      post :create, person: people(:staff_1).id
      assert_response :ok

      data = JSON.parse(@response.body, symbolize_names: true)[:data]
      data[:person_id].must_equal people(:staff_1).id
    end

    it "must 403 on a non-staff person" do
      post :create, person: people(:student_1).id
      assert_response :forbidden

      message = JSON.parse(@response.body, symbolize_names: true)[:message]
      message.must_equal "Must be an active staff member to check in as a helper."
    end
  end
end
