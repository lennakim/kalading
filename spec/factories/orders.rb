#encoding: UTF-8
FactoryGirl.define do
  factory :maintain_order, class: Order do
    address "单元测试888号"
    name "单元测试"
    phone_num "13888888888"
    car_location "京"
    car_num "N333M3"
    serve_datetime "2014-05-09 15:44"
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    service_type_ids [ServiceType.find_by(name: I18n.t(:auto_maintain_service_type_name)).id]
  end

end