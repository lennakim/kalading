FactoryGirl.define do
  factory :engineer do
    phone_num "15555555555"
    email "test_engineer_rspec@kalading.com"
    name "app"
    password  "12345678"
    association :city, factory: :beijing
    roles ["5"]
    # initialize_with { User.find_or_create_by(name: name)}
  end
end
