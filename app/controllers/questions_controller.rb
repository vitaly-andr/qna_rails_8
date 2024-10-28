class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_question, only: [ :show, :edit, :update, :destroy, :mark_best_answer, :unmark_best_answer ]

  def index
    @questions = policy_scope(Question)
    render template: 'questions/index', locals: { questions: @questions }

  end

  def show
    @best_answer = @question.best_answer
    @answers = @question.answers.where.not(id: @question.best_answer_id).order(updated_at: :desc)
    @links = @question.links

    @answer = @question.answers.build
    @answer.links.build
  end

  def new
    @question = Question.new
    @question.links.build
    @question.build_reward
    authorize @question
  end

  def edit
    authorize @question
    @question.links.build if @question.links.blank?
    @question.build_reward if @question.reward.blank?
  end

  def create
    @question = current_user.questions.build(question_params)
    authorize @question

    if @question.save
      questions = Question.all

      respond_to do |format|
        format.html { redirect_to @question, notice: "Question was successfully created." }
        format.turbo_stream { render 'questions/create', locals: { questions: questions } }
      end
    else
      @question.links.build if @question.links.blank?
      @question.build_reward if @question.reward.blank?
      respond_to do |format|
        format.html do
          flash[:alert] = @question.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity
        end
        format.turbo_stream do
          render 'questions/create_error', locals: { question: @question, message: @question.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    # return handle_unauthorized_update unless current_user.author_of?(@question)
    authorize @question

    @question.update(question_params) ? handle_successful_update : handle_failed_update
  end

  def destroy
    # return handle_unauthorized_destroy unless current_user.author_of?(@question)
    authorize @question

    @question.destroy
    handle_successful_destroy
  end

  def mark_best_answer
    @answer = @question.answers.find(params[:answer_id])
    authorize @question, :mark_best_answer?

    if @question.update(best_answer: @answer)
      @question.reward.update(user: @answer.author) if @question.reward
      @best_answer = @question.best_answer
      @answers = @question.answers.where.not(id: @question.best_answer_id).order(updated_at: :desc)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("answers", partial: 'answers/answers_list') }
        format.html { redirect_to @question, notice: 'Best answer selected.' }
      end

    else
      respond_to do |format|
        # format.turbo_stream { render turbo_stream: turbo_stream.replace('best_answer', partial: 'questions/best_answer', locals: { question: @question }), status: :unprocessable_entity } # Just for future
        format.html { redirect_to @question, alert: 'Failed to select the best answer.', status: :unprocessable_entity }
      end
    end
    # else
    #   redirect_to @question, alert: 'You are not authorized to select the best answer.', status: :forbidden
    # end
  end

  def unmark_best_answer
    authorize @question, :unmark_best_answer?
    if @question.update(best_answer: nil)
      @question.reward.update(user: nil) if @question.reward
      @answers = @question.answers.order(updated_at: :desc)
      respond_to do |format|
        format.html { redirect_to @question }
        format.turbo_stream { render turbo_stream: turbo_stream.update("answers", partial: 'answers/answers_list') }
      end
    else
      redirect_to @question, alert: 'Failed to unmark the best answer.', status: :unprocessable_entity
    end
    # else
    #   redirect_to @question, alert: 'You are not authorized to unmark the best answer.', status: :forbidden
    # end
  end

  private

  def set_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, :best_answer_id, files: [], links_attributes: [:id, :name, :url, :_destroy], reward_attributes: [:title, :image])
  end

  def handle_unauthorized_update
    respond_to do |format|
      format.html { redirect_to @question, alert: 'Only the author can edit this question.', status: :forbidden }
      format.turbo_stream { render turbo_stream: helpers.render_flash_alert('Only the author can edit this question.'), status: :forbidden }
    end
  end

  def handle_unauthorized_destroy
    respond_to do |format|
      format.html { redirect_to questions_path, alert: 'You can delete only your own questions.', status: :forbidden }
      format.turbo_stream { render turbo_stream: helpers.render_flash_alert('You can delete only your own questions.'), status: :forbidden }
    end
  end

  def handle_successful_update
    message = 'Question successfully updated.'
    respond_to do |format|
      format.html { redirect_to @question, notice: 'Question successfully updated.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(helpers.dom_id(@question), partial: 'questions/question', locals: { question: @question }),
          helpers.render_flash_notice('Question successfully updated.')
        ]
      end

    end
  end

  def handle_failed_update
    respond_to do |format|
      format.html { render :edit }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('question_form', partial: 'questions/form')
        ], status: :unprocessable_entity
      end
    end
  end

  def handle_successful_destroy
    respond_to do |format|
      if turbo_frame_request?
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@question),
            helpers.render_flash_notice('Your question was successfully deleted.')
          ]
        end
      else
        format.html { redirect_to questions_path, notice: "Your question was successfully deleted." }
      end
    end
  end

end

