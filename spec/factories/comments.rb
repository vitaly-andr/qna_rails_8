FactoryBot.define do
  factory :comment do
    body { "MyText" }
    association :author, factory: :user

    association :commentable, factory: :question

    trait :for_question do
      association :commentable, factory: :question
    end

    trait :for_answer do
      association :commentable, factory: :answer
    end
  end
end
