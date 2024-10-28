class CreateRewards < ActiveRecord::Migration[7.2]
  def change
    create_table :rewards do |t|
      t.string :title
      t.references :user, null: true, foreign_key: true
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
