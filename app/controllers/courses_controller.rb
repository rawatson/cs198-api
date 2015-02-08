class CoursesController < ApplicationController
  def index
    if params[:person_id].nil?
      fail 'Not implemented'
    else
      person = Person.select('id').find_by_id_flexible params[:person_id]

      if params[:student].nil?
        @courses = person.courses
      elsif params[:student]
        @courses = person.courses_taking
      else
        @courses = person.courses_staffing
      end

      render :index, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render status: :not_found, json: { data: {
      message: "Person not found" } }
  end

  def show
    fail 'Not implemented'
  end
end
