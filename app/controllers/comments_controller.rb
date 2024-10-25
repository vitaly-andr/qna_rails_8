class CommentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @commentable = find_commentable
    @comment = @commentable.comments.build
    authorize @comment

    # respond_to do |format|
    #   format.turbo_stream { render template: 'comments/new', locals: { commentable: @commentable, comment: @comment } }
    #   format.html { render template: 'comments/new', locals: { commentable: @commentable, comment: @comment  } }
    # end
  end
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params.merge(author: current_user))
    authorize @comment

    if @comment.save
      respond_to do |format|
        # format.html { redirect_back fallback_location: root_path }
        format.turbo_stream { render partial: 'comments/create', locals: { comment: @comment, commentable: @commentable } }
      end
    else
      # @comment = @commentable.comments.build
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'Comment could not be created.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(helpers.dom_id(@commentable, :form), partial: 'comments/form', locals: { commentable: @commentable, comment: @comment }),
          ], status: :unprocessable_entity
        end

      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_commentable
    if params[:question_id]
      Question.find(params[:question_id])
    elsif params[:answer_id]
      Answer.find(params[:answer_id])
    end
  end
end
