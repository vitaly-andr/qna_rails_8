# frozen_string_literal: true

module Api
  module V1
    class AnswersController < BaseController
      before_action :set_answer, only: [:show, :update, :destroy]
      before_action :set_question, only: [:create]

      def index
        answers = policy_scope(Answer).where(question_id: params[:question_id])
        render json: answers, each_serializer: AnswerSerializer
      end

      def show
        authorize @answer
        render json: @answer, serializer: AnswerSerializer
      end

      def create
        answer = @question.answers.new(answer_params.merge(author: current_user))
        authorize answer
        if answer.save
          render json: answer, serializer: AnswerSerializer, status: :created
        else
          render json: { errors: answer.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @answer
        if @answer.update(answer_params)
          render json: @answer, serializer: AnswerSerializer
        else
          render json: { errors: @answer.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @answer
        @answer.destroy
        head :no_content
      end

      private

      def set_answer
        @answer = Answer.find(params[:id])
      end

      def set_question
        @question = Question.find(params[:question_id])
      end

      def answer_params
        params.require(:answer).permit(:body)
      end
    end
  end
end
