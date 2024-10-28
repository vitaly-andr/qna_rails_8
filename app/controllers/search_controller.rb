class SearchController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:index]

  def index
    @query = params[:query]
    @model = params[:model]
    @results = []

    if @query.present?
      case @model
        when "questions"
          @results = Question.search(@query)
        when "answers"
          @results = Answer.search(@query)
        when "comments"
          @results = Comment.search(@query)
        when "users"
          @results = User.search(@query)
        else
          @results = (
            Question.search(@query).to_a +
              Answer.search(@query).to_a +
              Comment.search(@query).to_a +
              User.search(@query).to_a
          )
      end
    end

    respond_to do |format|
      format.html
      format.json do
        if @results.empty?
          render json: { search_results: [] }, status: :ok
        else
          render json: SearchResultsSerializer.serialize(@results, 'search_results'), status: :ok
        end
      end
    end
  end
end
