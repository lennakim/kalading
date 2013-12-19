#encoding: UTF-8
require 'CSV'

mann = '曼牌 Mann'
mann_brand = PartBrand.find_by name: mann

oil_filter = '机滤'
engine_oil = '机油'
cabin_filter = '空调滤清器'
air_filter = '空气滤清器'

oil_filter_type = PartType.find_by name: oil_filter
engine_oil_type = PartType.find_by name: engine_oil
cabin_filter_type = PartType.find_by name: cabin_filter
air_filter_type = PartType.find_by name: air_filter

c = 0
File.open 'auto_submodel_parts.csv', 'wb' do |f|
  AutoSubmodel.where(data_source: 0).each do |asm|
    next unless (p1 = asm.parts.find_by part_type: oil_filter_type)
    next unless (p2 = asm.parts.find_by part_type: engine_oil_type)
    next unless (p3 = asm.parts.find_by part_type: cabin_filter_type)
    next unless (p4 = asm.parts.find_by part_type: air_filter_type)
    
    [oil_filter_type, engine_oil_type, cabin_filter_type, air_filter_type].each do |t|
      asm.parts.where(part_type: t).each do |p|
        f.puts "#{asm.id},#{asm.full_name},#{p.part_type.name},#{p.part_brand.name},#{p.number},#{p.ref_price},#{p.id}"
      end
    end
    c += 1
  end
end 
puts c

parts = []
AutoSubmodel.where(data_source: 0).each do |asm|
  next unless (p1 = asm.parts.find_by part_type: oil_filter_type)
  next unless (p2 = asm.parts.find_by part_type: engine_oil_type)
  next unless (p3 = asm.parts.find_by part_type: cabin_filter_type)
  next unless (p4 = asm.parts.find_by part_type: air_filter_type)

  [oil_filter_type, engine_oil_type, cabin_filter_type, air_filter_type].each do |t|
    asm.parts.where(part_type: t).each do |p|
      parts << p
    end
  end
end

File.open 'parts_without_price.csv', 'wb' do |f|
  parts.uniq.select {|p| p.ref_price == 0.0}.each do |p|
    f.puts "#{p.id},#{p.part_type.name},#{p.part_brand.name},#{p.number},#{p.ref_price}"
  end
end 

# 427
# 198

File.open 'auto_submodels.csv', 'wb' do |f|
  f.puts 'ID,Name,发动机型号,曼牌机滤,隆丰ID'
  AutoSubmodel.where(data_source: 0).each do |asm|
    p = asm.parts.find_by part_brand: mann_brand, part_type: oil_filter_type
    f.puts "#{asm.id},#{asm.full_name.gsub(/,/,';')},#{asm.engine_model.gsub(/,/,';')},#{p ? p.number: ''},"
  end
end

File.open 'longfeng_auto_submodels.csv', 'wb' do |f|
  f.puts 'ID,Name,发动机型号,曼牌机滤'
  AutoSubmodel.where(data_source: 1).each do |asm|
    p = asm.parts.find_by part_brand: mann_brand, part_type: oil_filter_type
    f.puts "#{asm.id},#{asm.full_name.gsub(/,/,';')},#{asm.engine_model.gsub(/,/,';') if asm.engine_model},#{p ? p.number: ''},"
  end
end

# Merge duplicated longfeng auto submodels
asms = AutoSubmodel.where(data_source: 1).group_by {|m| m.full_name}.select {|k, v| v.size > 1}
asms.each do |k, v|
  v[0].auto_model = v[0].auto_model || v[1].auto_model
  v[0].parts = v[0].parts | v[1].parts
  v[0].orders = v[0].orders | v[1].orders
  v[0].save
  v[1].destroy
end

asms = AutoSubmodel.where(data_source: 1).select {|m| m.auto_model.nil?}

l_to_k = CSV.read 'longfeng_to_kalading_brand.csv', :headers => true, :encoding=>"GBK", :col_sep=>","
l_to_k.each do |x|
  if x[0] && x[2]
    b = AutoBrand.find(x[0])
    #File.open "#{b.name} mann.csv", 'wb' do |f|
    #  b.auto_models.each do |am|
    #    am.auto_submodels.each do |asm|
    #      p = asm.parts.find_by part_brand: mann_brand, part_type: oil_filter_type
    #      f.puts "#{asm.id},#{asm.full_name.gsub(/,/,';')},#{p ? p.number: ''},"
    #    end
    #  end
    #end
    b = AutoBrand.find(x[0])
    b1 = AutoBrand.find_by name_mann: x[2]
    File.open "#{b.name} longfeng.csv", 'wb' do |f|
      b1.auto_models.each do |am|
        am.auto_submodels.each do |asm|
          p = asm.parts.find_by part_brand: mann_brand, part_type: oil_filter_type
          f.puts "#{asm.id},#{asm.full_name.gsub(/,/,';')},#{p ? p.number: ''},"
        end
      end
    end if b1
  end
end
