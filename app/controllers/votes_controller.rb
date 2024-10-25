class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_votable
  after_action :skip_authorization

  def create

    @votable.vote_by(current_user, params[:value].to_i)
    render json: { rating: @votable.rating }

  end

  def destroy

    @votable.cancel_vote_by(current_user)
    render json: { rating: @votable.rating }

  end

  private

  def find_votable
    @votable = params[:votable_type].classify.constantize.find(params[:votable_id])
  end

end
