class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [ :new, :create ]
  before_action :set_answer, only: [ :edit, :update, :destroy ]


  def new
    @answer = @question.answers.build
    @answer.author = current_user
    @answer.links.build
  end

  def create
    @answer = @question.answers.build(answer_params)
    @answer.author = current_user
    authorize @answer

    respond_to do |format|
      if @answer.save
        @new_answer = @question.answers.build
        @new_answer.links.build
        format.html { redirect_to @question, notice: "Answer was successfully created." }
        format.turbo_stream { render 'answers/create', locals: { answer: @new_answer } }
      else
        @answers = @question.answers
        @answer.links.build if @answer.links.blank?
        format.html do
          render "questions/show", status: :unprocessable_entity
        end
        format.turbo_stream { render 'answers/create_error', status: :unprocessable_entity }
      end
    end
  end

  def edit
    @question = @answer.question

    authorize @answer

    @answer.links.build if @answer.links.blank?
  end

  def update
    @question = @answer.question
    authorize @answer

    if @answer.update(answer_params)
      respond_to do |format|
        format.html { redirect_to @answer.question, notice: 'Your answer was successfully updated.' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@answer), partial: 'answers/answer', locals: { answer: @answer }),
            helpers.render_flash_notice('Your answer was successfully updated.')
          ]
        end
      end
    else
      handle_failed_update
    end
  end

  def destroy
    @question = @answer.question
    respond_to do |format|
      authorize @answer

      @answer.destroy
      format.html { redirect_to @question, notice: "Your answer was successfully deleted." }
      format.turbo_stream do
        if turbo_frame_request?
          render turbo_stream: [
            turbo_stream.remove(@answer),
            helpers.render_flash_notice("Your answer was successfully deleted.")
          ]
        end
      end
    end
  end

  private

  def handle_unauthorized_update
    respond_to do |format|
      format.html { redirect_to @question, alert: 'You can update only your own answers.', status: :forbidden }
      format.turbo_stream { render turbo_stream: helpers.render_flash_alert('You can update only your own answers.'), status: :forbidden }
    end
  end

  def handle_failed_update

    respond_to do |format|
      format.html { render :edit, alert: 'Failed to update the answer. Please fix the errors.', status: :unprocessable_entity }
      format.turbo_stream { render turbo_stream: [
        turbo_stream.update(dom_id(@answer), partial: 'answers/form', locals: { answer: @answer }),
      ], status: :unprocessable_entity }
    end
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: [ :id, :name, :url, :_destroy ])
  end
end
