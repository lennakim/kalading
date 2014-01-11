#encoding: UTF-8

require 'CSV'

namespace :export_automodel do
  task :a => :environment do
    mann = '曼牌 Mann'
    mahle = '马勒 Mahle'

    fuel_filter =  PartType.find_by name: '燃油滤清器'
    mann_brand = PartBrand.find_by name: mann
    mahle_brand = PartBrand.find_by name: mahle
    
    File.open 'mann_mahle_asms.csv', 'w:UTF-8' do |f|
      mann_parts = []
      mahle_parts = []
      f.puts 'ID,品牌,名称,机油容量(升),排量,发动机型号'
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

      sh = Storehouse.find_by name: '北京 峻峰华亭仓库'    
      File.open 'mann_parts.csv', 'w:UTF-8' do |f|
        f.puts 'ID,品牌,类型,型号,售价(元),京东价(元),峻峰华亭进价(元)'
        mann_parts.sort_by {|x| x.part_type}.each do |p|
          next if p.part_type == fuel_filter
          pb = p.partbatches.where(storehouse_id: sh.id).asc(:created_at).last
          f.puts "#{p.id},#{p.part_brand.name},#{p.part_type.name},#{p.number},#{p.price.to_f},#{p.url_price.to_f},#{pb ? pb.price.to_f : 0.0}"
        end
      end
    
      File.open 'mahle_parts.csv', 'w:UTF-8' do |f|
        f.puts 'ID,品牌,类型,型号,售价(元),京东价(元),峻峰华亭进价(元)'
        mahle_parts.sort_by {|x| x.part_type}.each do |p|
          next if p.part_type == fuel_filter
          pb = p.partbatches.where(storehouse_id: sh.id).asc(:created_at).last
          f.puts "#{p.id},#{p.part_brand.name},#{p.part_type.name},#{p.number},#{p.price.to_f},#{p.url_price.to_f},#{pb ? pb.price.to_f : 0.0}"
        end
      end
      puts count
    end
  end
end

