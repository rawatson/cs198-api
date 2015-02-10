require "test_helper"

describe CoursesController do
  describe :index do
    it "gets courses for a person" do
      Person.all.each do |p|
        get :index, format: :json, person_id: p.id
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data.must_be_instance_of Array # list of people
        data.each { |c| p.courses.map(&:id).must_include c[:id] }
      end
    end

    it "gets courses taking for a student" do
      Person.all.each do |p|
        get :index, format: :json, person_id: p.id, student: true
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data.must_be_instance_of Array # list of people
        if p.courses_taking.empty?
          data.length.must_equal 0
        else
          data.length.must_be :>, 0
          data.each { |c| p.courses_taking.map(&:id).must_include c[:id] }
        end
      end
    end

    it "gets courses staffing for staff" do
      Person.all.each do |p|
        get :index, format: :json, person_id: p.id, student: false
        assert_response :success
        data = JSON.parse(@response.body, symbolize_names: true)[:data]
        data.must_be_instance_of Array # list of people
        if p.courses_staffing.empty?
          data.length.must_equal 0
        else
          data.length.must_be :>, 0
          data.each { |c| p.courses_staffing.map(&:id).must_include c[:id] }
        end
      end
    end
  end
end
