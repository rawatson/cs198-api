require "test_helper"

# To be handled correctly this spec must end with "Integration Test"
describe "Lair::HelperCheckinsFlow Integration Test" do
  fixtures :people

  it "shows newly created checkins in index and show" do
    staff = people(:staff_4)
    post "/lair/helpers.json", person: staff.id
    assert_response :created
    data = JSON.parse(response.body, symbolize_names: true)[:data]
    data[:person_id].must_equal staff.id

    get "/lair/helpers.json"
    assert_response :ok
    data = JSON.parse(response.body, symbolize_names: true)[:data]
    data.must_be :is_a?, Array
    match = data.select { |h| h[:person_id] == staff.id }
    match.length.must_equal 1
    match.first[:checked_out].must_equal false

    get "/lair/helpers/#{match.first[:id]}.json"
    assert_response :ok
    data = JSON.parse(response.body, symbolize_names: true)[:data]
    data[:person_id].must_equal staff.id
    data[:checked_out].must_equal false
  end

  it "allows you to delete created checkins" do
    staff = people(:staff_4)
    post "/lair/helpers.json", person: staff.id
    assert_response :created
    checkin_data = JSON.parse(response.body, symbolize_names: true)[:data]
    checkin_data[:checked_out].must_equal false
    checkin_data[:check_out_time].must_equal nil   # check_out_time must not be set

    delete "/lair/helpers/#{checkin_data[:id]}.json"
    assert_response :no_content

    get "/lair/helpers/#{checkin_data[:id]}.json"
    assert_response :ok
    updated_data = JSON.parse(response.body, symbolize_names: true)[:data]
    updated_data[:id].must_equal checkin_data[:id]
    updated_data[:checked_out].must_equal true
    updated_data[:check_out_time].must_be :is_a?, String # check_out_time set
    updated_data[:check_out_time].wont_equal nil

    # Deleting again shouldn't change content
    delete "/lair/helpers/#{checkin_data[:id]}.json"
    assert_response :no_content

    get "/lair/helpers/#{checkin_data[:id]}.json"
    assert_response :ok
    data = JSON.parse(response.body, symbolize_names: true)[:data]
    updated_data.must_equal data
  end
end
