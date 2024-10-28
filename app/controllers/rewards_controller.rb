class RewardsController < ApplicationController
  def index
    @rewards = policy_scope(Reward).includes(:question)
  end
end
