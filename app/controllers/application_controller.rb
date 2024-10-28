class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  after_action :verify_authorized, except: [:index, :show], unless: -> { devise_controller? || is_a?(SearchController) }
  after_action :verify_policy_scoped, only: :index, unless: -> { devise_controller? || is_a?(SearchController) }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  private

  AUTHORIZATION_ERROR_MESSAGES = {
    "answers" => {
      "edit" => "You can edit only your own answers.",
      "update" => "You can update only your own answers.",
      "destroy" => "You can delete only your own answers."
    },
    "questions" => {
      "edit" => "You can edit only your own questions.",
      "update" => "You can update only your questions.",
      "destroy" => "You can delete only your own questions.",
      "mark_best_answer" => "You are not authorized to select the best answer."
    },
    "votes" => {
      "create" => "You cannot vote for your own content.",
      "destroy" => "You can only remove your own vote."
    },
    "attachments" => {
      "destroy" => "You are not authorized to delete this file."
    },
    "comments" => {
      "create" => "You need to be signed in to add a comment."
    }
  }.freeze

  def user_not_authorized(exception)
    controller_name = params[:controller].to_s
    action_name = params[:action].to_s

    error_message = AUTHORIZATION_ERROR_MESSAGES.dig(controller_name, action_name) || "You are not authorized to perform this action."

    flash[:alert] = error_message

    respond_to do |format|
      format.html do
        case controller_name
          when "answers"
            question = Answer.find(params[:id]).question
            redirect_to question_path(question)
          when "questions"
            question = Question.find(params[:id])
            if action_name == "destroy"
              redirect_back(fallback_location: root_path)
            else
              redirect_to question_path(question)
            end
          else
            redirect_back(fallback_location: root_path)
        end
      end
      format.json do
        render json: { error: error_message }, status: :forbidden
      end
    end
  end
end
