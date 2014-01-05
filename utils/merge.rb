#encoding: UTF-8

# Runs in rails console
require 'CSV'

File.open 'merged.csv', 'wb' do |f|
  f.puts 'ID,Mann Name,ID,LongFeng Name'

  d = './utils/merge/'
  Dir.foreach(d) do |item|
    next if item == '.' or item == '..'
    puts d + item
    lines = CSV.read d + item, :headers => false, :encoding=>"GBK", :col_sep=>","
    lines.each do |l|
      next if l[0] == nil || l[4] == nil
      f.puts "#{l[0]},#{l[1]},#{l[4]},#{l[5]}"
    end
  end
end

d = './utils/merge/'
Dir.foreach(d) do |item|
  next if item == '.' or item == '..'
  puts d + item
  lines = CSV.read d + item, :headers => false, :encoding=>"GBK", :col_sep=>","
  lines.each do |l|
    next if l[0] == nil || l[4] == nil
    asm1 = AutoSubmodel.find l[0]
    asm2 = AutoSubmodel.find l[4]
    if asm1.nil?
      puts "#{l[1]} not found"
      next
    end
    if asm2.nil?
      puts "#{l[5]} not found"
      next
    end
    asm1.update_attributes(oil_filter_oe: asm2.oil_filter_oe, fuel_filter_oe: asm2.fuel_filter_oe, air_filter_oe: asm2.air_filter_oe )
    asm2.parts.each do |p|
      asm1.parts << p
      puts "Add part #{p.number} to #{asm1.full_name}"
    end

    asm2.orders.each do |p|
      asm1.orders << p
    end
    asm2.destroy
  end
end

mann = '曼牌 Mann'
mahle = '马勒 Mahle'

mann_brand = PartBrand.find_by name: mann
mahle_brand = PartBrand.find_by name: mahle

File.open 'mann_mahle_asms.csv', 'w:UTF-8' do |f|
  mann_parts = []
  mahle_parts = []
  f.puts 'ID,品牌,名称,机油容量,排量,发动机型号'
  count = 0
  AutoSubmodel.each do |asm|
    asm_mann_parts = asm.parts.where(part_brand: mann_brand).asc(:part_type)
    asm_mahle_parts = asm.parts.where(part_brand: mahle_brand).asc(:part_type)
    if asm_mann_parts.exists? && asm_mahle_parts.exists?
      if asm.auto_model.nil? || asm.auto_model.auto_brand.nil?
        ab = AutoBrand.find_or_create_by name: asm.full_name.split[0]
        am = ab.auto_models.find_or_create_by name: asm.full_name.split[1]
        am.auto_submodels << asm
        am.save
        puts "#{asm.full_name} belongs to nil model, #{ab.name}, #{am.name}"
      end

      f.puts "#{asm.id},#{asm.auto_model.auto_brand.name},#{asm.full_name.gsub(/,/,'')},#{asm.motoroil_cap},#{asm.engine_displacement},#{asm.engine_model}"
      count += 1
      mann_parts |= asm_mann_parts
      mahle_parts |= asm_mahle_parts
    end
  end

  File.open 'mann_parts.csv', 'w:UTF-8' do |f|
    f.puts 'ID,品牌,类型,型号'
    mann_parts.sort_by {|x| x.part_type}.each do |p|
      f.puts "#{p.part_brand.name},#{p.part_type.name},#{p.number}"
    end
  end

  File.open 'mahle_parts.csv', 'w:UTF-8' do |f|
    f.puts 'ID,品牌,类型,型号'
    mahle_parts.sort_by {|x| x.part_type}.each do |p|
      f.puts "#{p.id},#{p.part_brand.name},#{p.part_type.name},#{p.number}"
    end
  end
  puts count
end


AutoSubmodel.each do |asm|
  if asm.auto_model.nil? || asm.auto_model.auto_brand.nil?
    ab = AutoBrand.find_or_create_by name: asm.full_name.split[0]
    am = ab.auto_models.find_or_create_by name: asm.full_name.split[1]
    am.auto_submodels << asm
    am.save
    puts "#{asm.full_name} belongs to nil model, #{ab.name}, #{am.name}"
  end
end