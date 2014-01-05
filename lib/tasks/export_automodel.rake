#encoding: UTF-8

require 'CSV'

namespace :export_automodel do
  task :a => :environment do
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
  end
end

