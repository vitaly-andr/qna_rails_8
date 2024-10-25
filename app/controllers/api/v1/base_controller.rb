# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pundit
      include Doorkeeper::Helpers::Controller

      before_action :doorkeeper_authorize!
      before_action :set_current_user

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      def current_user
        return unless doorkeeper_token

        @current_user ||= User.find(doorkeeper_token.resource_owner_id)
      end

      def set_current_user
        @current_user = current_user
      end

      def user_not_authorized
        render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
      end
    end
  end
end
