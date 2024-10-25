FactoryBot.define do
  factory :link do
    name { "MyString" }
    url { "https://example.com" }
    association :linkable, factory: :question

    trait :for_question do
      association :linkable, factory: :question
    end

    trait :for_answer do
      association :linkable, factory: :answer
    end
  end
end