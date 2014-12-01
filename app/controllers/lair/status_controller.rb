class Lair::StatusController < ApplicationController
  def status
    render json: { data: LairState.take }
  end

  def update
    params.require :signups_enabled
    @state = LairState.take
    @state.signups_enabled = params[:signups_enabled]
    @state.save!
    render json: { data: @state }
  rescue ActionController::ParameterMissing => e
    render_missing_params e.param, ["signups_enabled"]
  rescue ActiveRecord::RecordInvalid
    render_validation_error @state
  end
end
