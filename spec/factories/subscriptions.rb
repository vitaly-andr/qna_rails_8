FactoryBot.define do
  factory :subscription do
    association :user
    association :subscribable, factory: :question

    trait :for_answer do
      association :subscribable, factory: :answer
    end
  end
end