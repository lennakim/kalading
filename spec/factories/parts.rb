#encoding: UTF-8
FactoryGirl.define do
  factory :mann_brand, class: PartBrand do
    name '曼牌 Mann'
    initialize_with { PartBrand.find_or_create_by(name: name)}
  end
  
  factory :oil_filter, class: PartType do
    name '机滤'
    initialize_with { PartType.find_or_create_by(name: name)}
  end

  factory :mann_part, class: Part do
    number 'C 2001'
    spec ''
    price Money.new(55.0)
    association :part_brand, factory: :mann_brand
    association :part_type, factory: :oil_filter
    initialize_with { Part.find_or_create_by(number: number)}
    before(:create) do |p|
      p.auto_submodels << create(:audi_a3_20_2012)
    end
  end
end