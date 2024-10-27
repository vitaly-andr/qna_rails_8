class AddAuthorToAnswers < ActiveRecord::Migration[7.2]
  def change
    add_reference :answers, :author, null: false, foreign_key: { to_table: :users }
  end
end
