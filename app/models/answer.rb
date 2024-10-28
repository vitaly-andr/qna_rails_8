class Answer < ApplicationRecord
  include Linkable
  include FileAttachable
  include Authorable
  include Votable
  include ActionView::RecordIdentifier
  include Subscribable
  searchkick


  has_many :comments, as: :commentable, dependent: :destroy

  belongs_to :question

  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank

  validates :body, presence: true
  after_create_commit :broadcast_answer
  after_create_commit :notify_subscribers


  after_update_commit do
    broadcast_update_to "questions",
                        target: "#{dom_id(self)}",
                        partial: "live_feed/answer",
                        locals: { answer: self }
  end

  after_destroy_commit do
    broadcast_remove_to "questions", target: "answer_#{id}"
  end

  private

  def broadcast_answer
    broadcast_prepend_to "questions", target: "question_#{question.id}_answers", partial: "live_feed/answer", locals: { answer: self }
  end

  def notify_subscribers
    NotificationService.call(self)
  end


end
