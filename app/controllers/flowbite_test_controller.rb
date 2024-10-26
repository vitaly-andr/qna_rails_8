class FlowbiteTestController < ApplicationController
  skip_policy_scope only: :index
  def index
  end
end
