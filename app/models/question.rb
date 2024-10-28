class Question < ApplicationRecord
  include Linkable
  include FileAttachable
  include Authorable
  include Votable
  include Subscribable


  before_destroy :reset_best_answer

  has_many :comments, as: :commentable, dependent: :destroy

  has_many :answers, dependent: :destroy
  has_one :reward, dependent: :destroy
  belongs_to :best_answer, class_name: 'Answer', optional: true

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :reward, allow_destroy: true, reject_if: :all_blank
  searchkick


  validates :title, :body, presence: true

  after_create_commit do
    broadcast_prepend_later_to "questions", target: "questions", partial: "live_feed/question", locals: { question: self }
  end

  after_update_commit do
    broadcast_replace_later_to "questions", target: "question_#{id}", partial: "live_feed/question", locals: { question: self }
  end

  after_destroy_commit do
    broadcast_remove_to "questions", target: "question_#{id}"
  end

  private

  def reset_best_answer
    self.best_answer = nil
  end

end
