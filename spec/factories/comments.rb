FactoryGirl.define do
  factory :comment do
    event
    user
    content { Faker::Lorem.sentence }
  end
end
