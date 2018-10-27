FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    password  { 'password' }
  end
end
