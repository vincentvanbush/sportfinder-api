FactoryGirl.define do
  factory :discipline do
    title { Faker::Commerce.department(1) }
  end
end
