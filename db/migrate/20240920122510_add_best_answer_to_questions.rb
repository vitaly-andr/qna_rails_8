class AddBestAnswerToQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :best_answer_id, :bigint
    add_foreign_key :questions, :answers, column: :best_answer_id

  end
end
