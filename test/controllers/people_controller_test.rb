require "test_helper"

describe PeopleController do
  describe :show do
    it "should query by id" do
      people.each do |p|
        get :show, id: p.id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:id].must_equal p.id
        data[:sunet_id].must_equal p.sunet_id
      end
    end

    it "should query by sunet id" do
      people.each do |p|
        get :show, id: p.sunet_id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data[:id].must_equal p.id
        data[:sunet_id].must_equal p.sunet_id
      end
    end
  end
end
