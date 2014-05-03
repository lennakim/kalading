#encoding: UTF-8
FactoryGirl.define do
  factory :user do
    phone_num "13988888888"
    email "test_engineer@kalading.com"
    password  "12345678"
    roles [5]
  end

  # This will use the User class (Admin would have been guessed)
  factory :admin, class: User do
    phone_num "13688888888"
    email "test_admin@kalading.com"
    password  "12345678"
    roles [1]
  end
end