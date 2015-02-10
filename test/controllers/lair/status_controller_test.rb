require "test_helper"

describe Lair::StatusController do
  it "should get status" do
    get :status, format: :json
    assert_response :success
    data = JSON.parse(@response.body, symbolize_names: true)[:data]
    data[:signups_enabled].must_equal LairState.take.signups_enabled
  end

  it "should update to false" do
    post :update, format: :json, signups_enabled: false
    assert_response :success
    data = JSON.parse(@response.body, symbolize_names: true)[:data]
    data[:signups_enabled].must_equal false
    LairState.take.signups_enabled.must_equal false
  end

  it "should update to false" do
    post :update, format: :json, signups_enabled: true
    assert_response :success
    data = JSON.parse(@response.body, symbolize_names: true)[:data]
    data[:signups_enabled].must_equal true
    LairState.take.signups_enabled.must_equal true
  end

  it "must require signups_enabled" do
    start = LairState.take.signups_enabled

    post :update, format: :json
    assert_response :bad_request
    data = JSON.parse(@response.body, symbolize_names: true)[:data]
    data[:message].must_equal "Missing required parameter(s)"
    data[:details][:missing].must_equal "signups_enabled"

    LairState.take.signups_enabled.must_equal start
  end
end
