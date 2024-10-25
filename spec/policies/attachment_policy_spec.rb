require 'rails_helper'

RSpec.describe AttachmentPolicy, type: :policy do
  include ActiveStorageHelper

  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, author: author) }
  let(:attached_file) { question.files.attach(create_file_blob); question.files.first }


  subject { described_class }

  permissions :destroy? do
    it "grants access if the user is the author of the parent record" do
      expect(subject).to permit(author, attached_file)
    end

    it "denies access if the user is not the author of the parent record" do
      expect(subject).not_to permit(user, attached_file)
    end
  end
end
