class PeopleController < ApplicationController
  def create
    fail "Not implemented"
  end

  def show
    begin
      @person = Person.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @person = Person.find_by sunet_id: params[:id]
    end

    return render :not_found, json: { data: { message: "Person not found" } } if @person.nil?
    render :show_limited
  end

  def update
    fail "Not implemented"
  end
end
