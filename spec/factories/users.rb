#encoding: UTF-8
FactoryGirl.define do
  factory :user do
    phone_num "33123113131313"
    email "test_engineer_rspec@kalading.com"
    name "app"
    password  "12345678"
    roles ["5"]
  end

  factory :baichebao_user, class: User do
    phone_num "444444444444444"
    email "baichebao_test@kalading.com"
    name "baichebao"
    password  "12345678"
    roles []
  end

  factory :weiche_user, class: User do
    phone_num "6666666666666666"
    email "weiche_test@kalading.com"
    name "微车下单专用"
    password  "12345678"
    roles []
  end

  factory :admin, class: User do
    phone_num "13688888888"
    email "test_admin@kalading.com"
    name "admin"
    password  "12345678"
    roles ["1"]
  end
end