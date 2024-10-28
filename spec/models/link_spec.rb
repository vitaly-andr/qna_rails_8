require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :url }
  end

  describe 'associations' do
    it { should belong_to(:linkable) }
  end

  describe 'URL validation' do
    let(:question) { create(:question) }
    it 'is valid with a valid URL' do
      link = Link.new(name: 'Valid Link', url: 'https://example.com', linkable: question)
      expect(link).to be_valid
    end

    it 'is invalid with an invalid URL' do
      link = Link.new(name: 'Invalid Link', url: 'invalid-url')
      expect(link).to_not be_valid
      expect(link.errors[:url]).to include('invalid-url is not a valid URL')
    end
  end

  describe '#gist?' do
    it 'returns true if the URL is a GitHub Gist' do
      link = Link.new(name: 'Gist Link', url: 'https://gist.github.com/example')
      expect(link.gist?).to be true
    end

    it 'returns false if the URL is not a GitHub Gist' do
      link = Link.new(name: 'Regular Link', url: 'https://example.com')
      expect(link.gist?).to be false
    end
  end
end
