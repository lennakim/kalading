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

AutoSubmodel.each do |asm|
  if asm.auto_model.nil? || asm.auto_model.auto_brand.nil?
    ab = AutoBrand.find_or_create_by name: asm.full_name.split[0]
    am = ab.auto_models.find_or_create_by name: asm.full_name.split[1]
    am.auto_submodels << asm
    am.save
    puts "#{asm.full_name} belongs to nil model, #{ab.name}, #{am.name}"
  end
end