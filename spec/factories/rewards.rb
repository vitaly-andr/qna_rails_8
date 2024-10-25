FactoryBot.define do
  factory :reward do
    title { "Best Answer Reward" }
    association :question
    user { nil }

    after(:build) do |reward|
      reward.image.attach(io: File.open("#{Rails.root}/spec/fixtures/files/reward_image.webp"), filename: 'reward_image.webp', content_type: 'image/webp')
    end
  end
end
