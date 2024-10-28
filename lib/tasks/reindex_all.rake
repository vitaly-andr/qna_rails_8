namespace :searchkick do
  desc "Reindex all Searchkick models"
  task reindex_all: :environment do
    models = [Question, Answer, Comment, User]

    models.each do |model|
      puts "Reindexing #{model.name}..."
      model.reindex
      puts "#{model.name} reindexing complete."
    end
  end
end
