require 'rails_helper'

RSpec.describe LinkPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, author: author) }
  let(:link) { create(:link, linkable: question) }

  subject { described_class }

  permissions :destroy? do
    it "grants access if the user is the author of the parent record" do
      expect(subject).to permit(author, link)
    end

    it "denies access if the user is not the author of the parent record" do
      expect(subject).not_to permit(user, link)
    end
  end
end
