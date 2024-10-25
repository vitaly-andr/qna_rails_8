require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should have_many(:answers).dependent(:destroy) }
  it { should belong_to(:author).class_name('User') }

  it { is_expected.to have_many_attached(:files) }
  it { should accept_nested_attributes_for :links}
  it { should have_many(:links).dependent(:destroy) }


  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it_behaves_like 'votable'

  describe 'accepts_nested_attributes_for :links' do
    let(:question) { create(:question) }
    let!(:link) { create(:link, linkable: question) }

    it 'deletes link if _destroy is set to true' do
      expect {
        question.update(links_attributes: [{ id: link.id, _destroy: '1' }])
      }.to change(question.links, :count).by(-1)
    end

    it 'does not delete link if _destroy is not set' do
      expect {
        question.update(links_attributes: [{ id: link.id, _destroy: '0' }])
      }.to_not change(question.links, :count)
    end
  end
  describe 'callbacks' do
    let(:question) { build(:question) }

    it 'broadcasts prepend to questions after create' do
      expect { question.save! }.to have_broadcasted_to("questions").with do |data|
        expect(data[:target]).to eq("questions")
        expect(data[:partial]).to eq("live_feed/question")
        expect(data[:locals][:question]).to eq(question)
      end
    end

    it 'broadcasts replace to questions after update' do
      question.save!
      expect { question.update!(title: 'Updated title') }.to have_broadcasted_to("questions").with do |data|
        expect(data[:target]).to eq("question_#{question.id}")
        expect(data[:partial]).to eq("live_feed/question")
        expect(data[:locals][:question]).to eq(question)
      end
    end

    it 'broadcasts remove from questions after destroy' do
      question.save!
      expect { question.destroy! }.to have_broadcasted_to("questions").with do |data|
        expect(data[:target]).to eq("question_#{question.id}")
      end
    end
  end

  it_behaves_like 'searchkick integration', Question, :title


end
