FactoryGirl.define do
  factory :message do
    event
    content { Faker::Lorem.paragraph(1) }
    attachment_url { Faker::Internet.url }
  end
end
