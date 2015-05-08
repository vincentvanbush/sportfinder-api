FactoryGirl.define do
  factory :vote do
    event
    user
    positive? { true }
  end
end
