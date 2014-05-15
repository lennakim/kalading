#encoding: UTF-8
FactoryGirl.define do
  factory :user do
    phone_num "13988888888"
    email "test_engineer@kalading.com"
    password  "12345678"
    roles [5]
  end

  factory :baichebao_user, class: User do
    phone_num "13788888888"
    email "baichebao@kalading.com"
    password  "12345678"
    roles []
  end

  factory :admin, class: User do
    phone_num "13688888888"
    email "test_admin@kalading.com"
    password  "12345678"
    roles [1]
  end
end