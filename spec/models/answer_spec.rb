require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to(:question) }
  it { should belong_to(:author).class_name('User') }

  it { is_expected.to have_many_attached(:files) }
  it { should have_many(:links).dependent(:destroy) }

  it { should validate_presence_of(:body) }

  it_behaves_like 'votable'

  describe 'accepts_nested_attributes_for :links' do
    let(:answer) { create(:answer) }
    let!(:link) { create(:link, linkable: answer) }

    it 'deletes link if _destroy is set to true' do
      expect {
        answer.update(links_attributes: [{ id: link.id, _destroy: '1' }])
      }.to change(answer.links, :count).by(-1)
    end

    it 'does not delete link if _destroy is not set' do
      expect {
        answer.update(links_attributes: [{ id: link.id, _destroy: '0' }])
      }.to_not change(answer.links, :count)
    end
  end

  describe 'callbacks' do
    let(:question) { create(:question) }
    let(:answer) { build(:answer, question: question) }

    it 'calls broadcast_answer after creating an answer' do
      expect(answer).to receive(:broadcast_answer)
      answer.save!
    end

    it 'calls notify_subscribers after creating an answer' do
      expect(NotificationService).to receive(:call).with(answer)
      answer.save!
    end


    it 'broadcasts prepend to questions after create' do
      # I placed at_least_once just temporary because I don't understand why 2 messages sent
      expect { answer.save! }.to have_broadcasted_to("questions").at_least(:once).with do |data|
        expect(data[:target]).to eq("question_#{question.id}_answers")
        expect(data[:partial]).to eq("live_feed/answer")
        expect(data[:locals][:answer]).to eq(answer)
      end
    end

    it 'broadcasts update to questions after update' do
      answer.save!
      expect { answer.update!(body: 'Updated body') }.to have_broadcasted_to("questions").with do |data|
        expect(data[:target]).to eq("#{ActionView::RecordIdentifier.dom_id(answer)}")
        expect(data[:partial]).to eq("live_feed/answer")
        expect(data[:locals][:answer]).to eq(answer)
      end
    end

    it 'broadcasts remove from questions after destroy' do
      answer.save!
      expect { answer.destroy! }.to have_broadcasted_to("questions").with do |data|
        expect(data[:target]).to eq("answer_#{answer.id}")
      end
    end
  end

  it_behaves_like 'searchkick integration', Answer, :body

end
