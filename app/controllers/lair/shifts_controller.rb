class Lair::ShiftsController < ApplicationController
  def index
    conditions = build_query_params params
    query = HelperShift
    conditions.each do |c|
      query = query.where c
    end
    @shifts = query
    render :index
  end

  def create
    fail 'Not yet implemented'
  end

  def update
    fail 'Not yet implemented'
  end

  def destroy
    fail 'Not yet implemented'
  end

  private

  def build_query_params(params)
    params = params.permit(:person_id, :before, :after)
    conditions = []

    # if before and after are not specified, default to after now.
    if params.key? :after
      conditions << ["start_time >= ? ", params[:after]]
    elsif !params.key? :before
      conditions << ["start_time >= ? ", DateTime.now]
    end

    conditions << ["start_time <= ?", params[:before]] if params.key? :before
    conditions << { person_id: params[:person_id] } if params.key? :person_id

    conditions
  end
end
