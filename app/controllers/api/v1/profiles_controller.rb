# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < BaseController
      def me
        authorize current_user, policy_class: ProfilePolicy
        render json: current_user, serializer: ProfileSerializer
      end

      def index
        users = User.where.not(id: current_user.id)
        authorize users, policy_class: ProfilePolicy
        render json: users, each_serializer: ProfileSerializer
      end
    end
  end
end
