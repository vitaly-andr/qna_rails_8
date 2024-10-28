# frozen_string_literal: true

class OauthBaseController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized
  rescue_from StandardError, with: :handle_standard_error

  before_action :log_request
  after_action :log_response

  private

  def api_logger
    @api_logger ||= Logger.new(Rails.root.join('log/API_log.log'))
  end

  def handle_record_not_found(exception)
    api_logger.error "RecordNotFound: #{exception.message}"
    render json: { error: 'Resource not found', message: exception.message }, status: :not_found
  end

  def handle_not_authorized(exception)
    api_logger.error "NotAuthorizedError: #{exception.message}"
    render json: { error: 'You are not authorized to perform this action', message: exception.message }, status: :forbidden
  end

  def handle_standard_error(exception)
    log_error(exception)
    render json: { error: 'An error occurred', message: exception.message }, status: :internal_server_error
  end

  def log_request
    api_logger.info "OAuth Request: #{request.method} #{request.fullpath}"
    api_logger.info "Parameters: #{params.except(:password).to_unsafe_h}"
  end

  def log_response
    response_summary = {
      status: response.status,
      content_type: response.content_type,
      body_preview: response.body&.truncate(100) # Укороченный просмотр тела ответа (максимум 100 символов)
    }

    api_logger.info "OAuth Response: #{response_summary}"
  end

  def log_error(exception)
    api_logger.error "Error: #{exception.class.name} - #{exception.message}"
    api_logger.error exception.backtrace.join("\n")
  end
end
