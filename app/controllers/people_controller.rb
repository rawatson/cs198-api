class PeopleController < ApplicationController
  def create
    fail "Not implemented"
  end

  def show
    @person = Person.find_by_id_flexible params[:id]
    fail ActiveRecord::RecordNotFound if @person.nil?
    render :show_limited
  rescue ActiveRecord::RecordNotFound
    return render status: :not_found, json: { data: { message: "Person not found" } }
  end

  def update
    fail "Not implemented"
  end
end
