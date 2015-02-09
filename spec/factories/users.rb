#encoding: UTF-8
FactoryGirl.define do
  factory :user do
    phone_num "38910721074"
    email "test_engineer_rspec@kalading.com"
    name "app"
    password  "12345678"
    association :city, factory: :beijing
    roles ["5"]
    initialize_with { User.find_or_create_by(name: name)}
  end

  factory :baichebao_user, class: User do
    phone_num "38910721075"
    email "baichebao_test@kalading.com"
    name "baichebao"
    password  "12345678"
    association :city, factory: :beijing
    roles []
  end

  factory :weiche_user, class: User do
    phone_num "48910721881"
    email "weiche_test@kalading.com"
    name "微车下单专用"
    password  "12345678"
    association :city, factory: :beijing
    roles []
  end

  factory :admin, class: User do
    phone_num "13688888888"
    email "test_admin@kalading.com"
    name "admin"
    password  "12345678"
    association :city, factory: :beijing
    roles ["1"]
  end
end