# frozen_string_literal: true

module Api
  module V1
    class CommentsController < BaseController

      def index
        comments = policy_scope(Comment).where(commentable: find_commentable)
        render json: comments, each_serializer: CommentSerializer
      end

      private

      def find_commentable
        if params[:question_id]
          Question.find(params[:question_id])
        elsif params[:answer_id]
          Answer.find(params[:answer_id])
        end
      end
    end
  end
end
