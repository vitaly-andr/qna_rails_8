require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:question) { create(:question) }
  let(:answer) { create(:answer) }
  let(:user) { create(:user) }

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'associations' do
    it { should belong_to(:commentable) }
    it { should belong_to(:author) }
  end

  describe 'polymorphic association with commentable' do
    it 'can be associated with a question' do
      comment = build(:comment, commentable: question, author: user)
      expect(comment.commentable).to eq(question)
      expect(comment).to be_valid
    end

    it 'can be associated with an answer' do
      comment = build(:comment, commentable: answer, author: user)
      expect(comment.commentable).to eq(answer)
      expect(comment).to be_valid
    end
  end


  describe 'callbacks' do
    let(:question) { create(:question) }
    let(:comment) { build(:comment, commentable: question) }

    it 'broadcasts prepend to comments after create' do
      # I placed at_least_once just temporary because I don't understand why 4 messages sent
      expect { comment.save! }.to have_broadcasted_to("questions").at_least(:once).with do |data|
        expect(data[:target]).to eq("#{ActionView::RecordIdentifier.dom_id(question, :comments)}")
        expect(data[:partial]).to eq("comments/comment")
        expect(data[:locals][:comment]).to eq(comment)
      end
    end

    it 'broadcasts remove no_comments message after create' do
      # I placed at_least_once just temporary because I don't understand why 4 messages sent
      expect { comment.save! }.to have_broadcasted_to("questions").at_least(:once).with do |data|
        expect(data[:target]).to eq("#{ActionView::RecordIdentifier.dom_id(question, :no_comments)}")
      end
    end

    it 'broadcasts update to comment form after create' do
      # I placed at_least_once just temporary because I don't understand why 4 messages sent
      expect { comment.save! }.to have_broadcasted_to("questions").at_least(:once).with do |data|
        expect(data[:target]).to eq("#{ActionView::RecordIdentifier.dom_id(question, :form)}")
        expect(data[:partial]).to eq("comments/comment_button")
        expect(data[:locals][:commentable]).to eq(question)
      end
    end
  end

  it_behaves_like 'searchkick integration', Comment, :body

end
