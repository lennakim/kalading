#encoding: UTF-8
FactoryGirl.define do
  factory :auto_maintain, class: ServiceType do
    name '换机油机滤'
    price Money.new(150.0)
    initialize_with { ServiceType.find_or_create_by(name: name)}
  end
end