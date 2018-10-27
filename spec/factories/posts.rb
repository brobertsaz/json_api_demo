FactoryBot.define do
  factory :post do
    user
    title     { Faker::Hipster.sentence(3) }
    content   { Faker::Hipster.paragraph(2) }
    rating    { rand(1..10) }
    category  { %w[Programming Gaming].sample }
  end
end
