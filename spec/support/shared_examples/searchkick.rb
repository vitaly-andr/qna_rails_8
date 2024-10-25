
RSpec.shared_examples 'searchkick integration' do |model_class, search_field|
  describe 'searchkick integration' do
    it "includes searchkick" do
      expect(model_class).to respond_to(:searchkick)
    end

    describe 'reindex after save' do
      before do
        allow(model_class.search_index).to receive(:reindex)
      end

      it 'calls reindex after create' do
        create(model_class.name.underscore.to_sym)
        expect(model_class.search_index).to have_received(:reindex).at_least(:once)
      end
    end

    describe 'search functionality' do
      before do
        model_class.reindex
        model_class.search_index.refresh
      end

      it 'returns correct results from search' do
        searchable_item = create(model_class.name.underscore.to_sym, search_field => "How to integrate searchkick in Rails?")
        non_searchable_item = create(model_class.name.underscore.to_sym, search_field => "Unrelated content")
        model_class.search_index.refresh

        results = model_class.search("searchkick")
        expect(results).to include(searchable_item)
        expect(results).not_to include(non_searchable_item)
      end
    end
  end
end
