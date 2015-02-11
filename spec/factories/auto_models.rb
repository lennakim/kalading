#encoding: UTF-8
FactoryGirl.define do
  factory :audi, class: AutoBrand do
    name '奥迪(进口)'
    name_pinyin 'aodi'
    data_source 2
    service_level 1
    initialize_with { AutoBrand.find_or_create_by(name: name)}
  end
  
  factory :audi_a3, class: AutoModel do
    name 'A3'
    name_pinyin 'a3'
    data_source 2
    service_level 1
    association :auto_brand, factory: :audi
    initialize_with { AutoModel.find_or_create_by(name: name)}
  end

  factory :audi_a3_20_2012, class: AutoSubmodel do
    name '2.0TFSI 2012.11-2014'
    data_source 2
    service_level 1
    motoroil_cap 4.3
    engine_displacement '2.0T'
    engine_model 'CJXC、CJXB'
    year_range '2012.11-2014'
    association :auto_model, factory: :audi_a3
    initialize_with { AutoSubmodel.find_or_create_by(name: name)}
    before(:create) do |a|
      a.full_name = a.auto_model.auto_brand.name + a.auto_model.name + a.name
      a.full_name_pinyin = a.auto_model.auto_brand.name_pinyin + a.auto_model.name_pinyin + a.name
    end
  end
end