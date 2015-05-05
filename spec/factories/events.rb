FactoryGirl.define do
  factory :event do
    discipline
    user
    title { Faker::Company.name + ' vs ' + Faker::Company.name }
    description { Faker::Lorem.sentence }
    venue { Faker::Address.city }
    start_date { Faker::Date.forward(30) }
  end
end
