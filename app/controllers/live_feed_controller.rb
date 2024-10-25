class LiveFeedController < ApplicationController
  def index
    @questions = policy_scope(Question).includes(:answers).order(created_at: :desc)
  end
end