FactoryBot.define do
  factory :vendor do
    name { Faker::Company.name }
    description { Faker::Company.catch_phrase }
    contact_name { Faker::TvShows::RuPaul.queen }
    contact_phone { Faker::PhoneNumber.phone_number }
    credit_accepted { Faker::Boolean.boolean }
  end
end