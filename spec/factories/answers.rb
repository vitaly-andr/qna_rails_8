FactoryBot.define do
  factory :answer do
    sequence(:body) { |n| "Answer text #{n}" }
    association :question
    association :author, factory: :user
    trait :invalid do
      body { nil }
    end
  end
end
