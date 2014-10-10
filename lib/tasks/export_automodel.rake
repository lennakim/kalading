# encoding: UTF-8

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

  task :b => :environment do
    
    oil_filter = PartType.find_by name: '机滤'
    puts 'oil_filter not found' or exit if oil_filter.nil?
    air_filter = PartType.find_by name: '空气滤清器'
    puts 'air_filter not found' or exit if air_filter.nil?
    cabin_filter = PartType.find_by name: '空调滤清器'
    puts 'cabin_filter not found' or exit if cabin_filter.nil?
    fuel_filter = PartType.find_by name: '燃油滤清器'
    puts 'fuel_filter not found' or exit if fuel_filter.nil?

    mann = PartBrand.find_by name: '曼牌 Mann'
    puts 'mann not found' or exit if mann.nil?
    mahle = PartBrand.find_by name: '马勒 '
    puts 'mahle not found' or exit if mahle.nil?
    sofima = PartBrand.find_by name: '索菲玛 Sofima'
    puts 'sofima not found' or exit if sofima.nil?

    if nil
      asms = CSV.read 'utils/longfeng.csv', :headers => false, :encoding=>"GBK", :col_sep=>","
      puts "auto submodels count #{asms.count}"
      
      asms.each do |asm|
        next if !asm[3] || !asm[4] || !asm[5]
        #puts 'brand: ' + asm[3]
        #puts asm[3].split('/')[0]
        #puts 'model: ' + asm[4]
        #puts asm[4].split('/')[0]
        #puts 'submodel: ' + asm[5]
        #puts asm[5].split('/')[0]
        #puts 'engine model: ' + asm[6]
        #puts 'year range: ' + asm[7]
        #puts 'oil filter OE: ' + asm[8]
        #puts 'LAMA oil filter: ' + asm[9]
        #puts 'fuel filter OE: ' + asm[10]
        #puts 'LAMA fuel filter: ' + asm[11]
        #puts 'air filter OE: ' + asm[12]
        #puts 'LAMA air filter: ' + asm[13]
        #puts 'cabin filter OE: ' + asm[14]
        #puts 'LAMA cabin filter: ' + asm[15]
        #puts 'LAMA cabin filter: ' + asm[16]
        #puts 'Mahle oil filter: ' + asm[17] if asm[17]
        #puts 'Mahle fuel filter: ' + asm[18] if asm[18]
        #puts 'Mahle air filter: ' + asm[19] if asm[19]
        #puts 'Mahle cabin filter: ' + asm[20] if asm[20]
        #puts 'Mahle cabin filter: ' + asm[21] if asm[21]
        #puts 'Mann oil filter: ' + asm[22] if asm[22]
        #puts 'Mann fuel filter: ' + asm[23] if asm[23]
        #puts 'Mann air filter: ' + asm[24] if asm[24]
        #puts 'Mann cabin filter: ' + asm[25] if asm[25]
        #puts 'Sofima oil filter: ' + asm[26] if asm[26]
        #puts 'Sofima fuel filter: ' + asm[27] if asm[27]
        #puts 'Sofima air filter: ' + asm[28] if asm[28]
        #puts 'Sofima cabin filter: ' + asm[29] if asm[29]
      
        parts = []
        create_part = Proc.new do |number, pb, pt|
          s = number.gsub(/\s+/, "")
          p = Part.find_by number: /.*#{s}.*/i, part_brand_id: pb.id, part_type_id: pt.id
          p = Part.find_or_create_by number: number, part_brand_id: pb.id, part_type_id: pt.id if ! p
          parts << p
        end
        
        create_part.call(asm[17], mahle, oil_filter) if asm[17]
        create_part.call(asm[18], mahle, fuel_filter) if asm[18]
        
        if asm[19]
          filters = asm[19].split '，'
          filters.each do |f|
            create_part.call(f, mahle, air_filter)
          end
        end
        create_part.call(asm[20], mahle, cabin_filter) if asm[20]
        create_part.call(asm[21], mahle, cabin_filter) if asm[21]
  
        create_part.call(asm[22], mann, oil_filter) if asm[22]
        create_part.call(asm[23], mann, fuel_filter) if asm[23]
        create_part.call(asm[24], mann, air_filter) if asm[24]
     
        if asm[25]
          filters = asm[25].split('/')
          if filters.length == 2 && filters[1].length == 1
            filters = [filters.join('/')]
          end
          filters.each do |f|
            create_part.call(f, mann, cabin_filter)
          end 
        end
        
        create_part.call(asm[26], sofima, oil_filter) if asm[26]
        create_part.call(asm[27], sofima, fuel_filter) if asm[27]
        create_part.call(asm[28], sofima, air_filter) if asm[28]
        create_part.call(asm[28], sofima, cabin_filter) if asm[28]
  
        ab = AutoBrand.find_or_create_by name: asm[3].split('/')[0]
        am = ab.auto_models.find_or_create_by name: asm[4]
        auto_submodel = AutoSubmodel.find_or_create_by name: asm[5], auto_model_id: am.id
        asm[7] = '' if asm[7].nil?
        full_name = asm[3].split('/')[0] + ' ' + asm[4].split('/')[0] + ' ' + asm[5].split('/')[0] + ' ' + asm[7]
        auto_submodel.update_attributes( full_name: full_name, full_name_pinyin: PinYin.of_string(full_name.gsub(/\s+/, "")).join.gsub(/zhang/, 'chang'),
          engine_model: asm[6],
          data_source: 1,
          year_range: asm[7],
          oil_filter_oe: asm[8],
          fuel_filter_oe: asm[10],
          air_filter_oe: asm[12],
          service_level: 0 )
        parts.each do |p|
          auto_submodel.parts << p
        end
      end
    end

    sh = Storehouse.find_by name: '北京 峻峰华亭仓库'
    sh.partbatches.each do |pb|
      puts "part batch error: #{pb.id}" or exit if pb.part.nil?
      if !pb.part.auto_submodels.exists? && pb.part.part_brand == mahle
        n = pb.part.number.gsub(/\s+/, "")
        Part.where(number: /#{n}/i).each do |p|
          next if p == pb.part
          p.auto_submodels.each do |asm|
            pb.part.auto_submodels << asm
            asm.parts << pb.part
          end

          p.orders.each do |o|
            pb.part.orders << o
            o.parts << pb.part
          end

          p.destroy
        end
      end
    end

    parts = []
    sh.partbatches.each do |pb|
      parts << pb.part if !pb.part.auto_submodels.exists? && pb.part.part_brand == mahle
    end

    File.open '峻峰华亭无匹配车型的配件 王哲 01162014.csv', 'w:UTF-8' do |f|
      parts.uniq.sort {|x,y| x.part_brand.name <=> y.part_brand.name}.each do |p|
        f.puts "#{p.part_brand.name},#{p.part_type.name},#{p.number}"
      end
    end
  end   
  
  task :c => :environment do
    oil_filter = PartType.find_by name: '机滤'
    puts 'oil_filter not found' or exit if oil_filter.nil?
    air_filter = PartType.find_by name: '空气滤清器'
    puts 'air_filter not found' or exit if air_filter.nil?
    cabin_filter = PartType.find_by name: '空调滤清器'
    puts 'cabin_filter not found' or exit if cabin_filter.nil?

    asms = []
    sh = Storehouse.find_by name: '北京 峻峰华亭仓库'
    oil_filters = []
    air_filters = []
    cabin_filters = []
    sh.partbatches.each do |pb|
      asms += pb.part.auto_submodels
      oil_filters << pb.part if pb.part.part_type == oil_filter
      air_filters << pb.part if pb.part.part_type == air_filter
      cabin_filters << pb.part if pb.part.part_type == cabin_filter
    end
    asms.uniq!

    File.open '峻峰华亭可保养车型列表 王哲 01162014.csv', 'w:UTF-8' do |f|
      mann_parts = []
      mahle_parts = []
      f.puts 'ID,品牌,名称,机油容量(升),发动机型号'
      count = 0
      asms.sort {|x,y| x.auto_model.auto_brand.name <=> y.auto_model.auto_brand.name}.each do |asm|
        oil_f = nil
        asm.parts.where(part_type: oil_filter).each do |p|
          if oil_filters.include? p
            oil_f = p
            break
          end
        end
        next if oil_f.nil?

        air_f = nil
        asm.parts.where(part_type: air_filter).each do |p|
          if air_filters.include? p
            air_f = p
            break
          end
        end
        next if air_f.nil?

        cabin_f = nil
        asm.parts.where(part_type: cabin_filter).each do |p|
          if cabin_filters.include? p
            cabin_f = p
            break
          end
        end
        next if cabin_f.nil?
        
        em = asm.engine_model
        em = em.gsub(/,/,'').gsub(/\s+/,' ') if em
        f.puts "#{asm.id},#{asm.auto_model.auto_brand.name},#{asm.full_name.gsub(/,/,'').gsub(/\s+/,' ')},#{asm.motoroil_cap},#{em}"
        count += 1
      end
      puts "#{count} auto submodels"
    end
  end

  # merge duplicated longfeng auto submodels
  task :d => :environment do
    #AutoBrand.each do |ab|
    #  ab.auto_models.each do |am|
    #    am.destroy if am.auto_submodels.empty?
    #  end
    #end
    AutoBrand.where(name: /.*\/.*/).each do |ab|
      ab_cn = AutoBrand.find_by name: ab.name.split('/')[0]
      if ab_cn
        ab.auto_models.each do |am|
          am_cn = ab_cn.auto_models.find_or_create_by name: am.name
          am.auto_submodels.each do |asm|
            asm_cn = am_cn.auto_submodels.find_or_create_by name: asm.name
            asm_cn.update_attributes(:engine_model => asm.engine_model,
            :year_range => asm.year_range,
            :full_name_pinyin => asm.full_name_pinyin,
            :full_name => asm.full_name,
            :oil_filter_oe => asm.oil_filter_oe,
            :fuel_filter_oe => asm.fuel_filter_oe,
            :air_filter_oe => asm.air_filter_oe )
            asm.parts.each do |p|
              asm_cn.parts << p
            end
          end
        end
        ab.destroy
      end
    end
  end

  # merge duplicated parts
  task :e => :environment do
    Part.where(number: /.*\s.*/).asc(:number).each do |p|
      n = p.number.gsub(/\s+/,'')
      p.part_brand.parts.where(number: /#{n}.*/i, part_type: p.part_type).each do |pp|
        pp.auto_submodels.each do |asm|
          p.auto_submodels << asm
          asm.parts << p
        end
        
        pp.orders.each do |o|
          p.orders << o
          o.parts << p
        end

        pp.partbatches.each do |pb|
          p.partbatches << pb
        end

        pp.urlinfos.each do |ui|
          p.urlinfos << ui
        end
        pp.destroy
      end
    end
  end
  
  task :f => :environment do
    
    oil_filter = PartType.find_by name: '机滤'
    puts 'oil_filter not found' or exit if oil_filter.nil?
    air_filter = PartType.find_by name: '空气滤清器'
    puts 'air_filter not found' or exit if air_filter.nil?
    cabin_filter = PartType.find_by name: '空调滤清器'
    puts 'cabin_filter not found' or exit if cabin_filter.nil?

    mann = PartBrand.find_by name: '曼牌 Mann'
    puts 'mann not found' or exit if mann.nil?
    mahle = PartBrand.find_by name: '马勒 '
    puts 'mahle not found' or exit if mahle.nil?
    sofima = PartBrand.find_by name: '索菲玛 Sofima'
    puts 'sofima not found' or exit if sofima.nil?
    hengst = PartBrand.find_by name: '汉格斯特 Hengst'
    puts 'hengst not found' or exit if hengst.nil?

    sh = Storehouse.find_by name: '北京 峻峰华亭仓库'
    oil_filters = []
    air_filters = []
    cabin_filters = []
    sh.partbatches.each do |pb|
      oil_filters << pb.part if pb.part.part_type == oil_filter
      air_filters << pb.part if pb.part.part_type == air_filter
      cabin_filters << pb.part if pb.part.part_type == cabin_filter
    end

    File.open '峻峰华亭可保养车型和配件 王哲 01272014.csv', 'w:UTF-8' do |f|
      f.puts 'ID,品牌,名称,发动机型号,4S店机油量,经验机油量,曼牌机滤,曼牌空气滤,曼牌空调滤,马勒机滤,马勒空气滤,马勒空调滤,索菲玛机滤,索菲玛空气滤,索菲玛空调滤,汉格斯特机滤,汉格斯特空气滤,汉格斯特空调滤'
      lines = CSV.read 'utils/峻峰华亭可操作车型 王哲  20130116 亚伟.csv', :headers => true, :encoding=>"GBK", :col_sep=>","
      puts lines.length
      nil_part = Part.new number: ''
      lines.each do |l|
        next if l[10] != '可操作' && l[10] != '未确认'
        asm = AutoSubmodel.find l[0]
        p1 = asm.parts.find_by(part_brand: mann, part_type: oil_filter) || nil_part
        p2 = asm.parts.find_by(part_brand: mann, part_type: air_filter) || nil_part
        p3 = asm.parts.find_by(part_brand: mann, part_type: cabin_filter) || nil_part
        p4 = asm.parts.find_by(part_brand: mahle, part_type: oil_filter) || nil_part
        p5 = asm.parts.find_by(part_brand: mahle, part_type: air_filter) || nil_part
        p6 = asm.parts.find_by(part_brand: mahle, part_type: cabin_filter) || nil_part
        p7 = asm.parts.find_by(part_brand: sofima, part_type: oil_filter) || nil_part
        p8 = asm.parts.find_by(part_brand: sofima, part_type: air_filter) || nil_part
        p9 = asm.parts.find_by(part_brand: sofima, part_type: cabin_filter) || nil_part
        p10 = asm.parts.find_by(part_brand: hengst, part_type: oil_filter) || nil_part
        p11 = asm.parts.find_by(part_brand: hengst, part_type: air_filter) || nil_part
        p12 = asm.parts.find_by(part_brand: hengst, part_type: cabin_filter) || nil_part
        f.puts "#{l[0]},#{l[1]},#{l[2]},#{l[4]},#{l[5]},#{l[8]},#{p1.number},#{p2.number},#{p3.number},#{p4.number},#{p5.number},#{p6.number},#{p7.number},#{p8.number},#{p9.number},#{p10.number},#{p11.number},#{p12.number}"
        
        asm.update_attributes( full_name: l[2], full_name_pinyin: PinYin.of_string(l[2].gsub(/\s+/, "")).join.gsub(/zhang/, 'chang') )
        asm.auto_model.auto_brand.update_attributes name: l[1]
      end
    end
  end
  
  # export all auto submodels
  task :g => :environment do
    lines = CSV.read 'utils/峻峰华亭可操作车型 王哲  20130116 亚伟.csv', :headers => true, :encoding=>"GBK", :col_sep=>","
    puts lines.length
    verified_asms = {}
    lines.each do |l|
      next if l[10] != '可操作' && l[10] != '未确认'
      verified_asms[l[0]] = 1  
    end

    AutoBrand.each do |ab|
      begin
        File.open 'utils\\asms\\' + ab.name.gsub('/',' ') + '.csv', 'w:UTF-8' do |f|
          f.puts 'ID,品牌,型号,款式,年代,发动机型号,是否校验过,重复车型ID'
          ab.auto_models.asc(:name).each do |am|
            am.auto_submodels.asc(:name).each do |asm|
              asm.engine_model.gsub!(',',' ') if asm.engine_model
              f.puts "#{asm.id},#{ab.name.gsub('/','|')},#{am.name.gsub(',',' ')},#{asm.name.gsub(',',' ')},#{asm.year_range},#{asm.engine_model},#{verified_asms[asm.id.to_s]},"
            end
          end
        end
      rescue
        puts "#{ab.name} error"
      end
    end
  end

  # Csv to Xls convertion, only can be used in irb
  task :h => :environment do
    require 'spreadsheet'
    require 'CSV'
    ['utils\\mann\\', 'utils\\longfeng\\'].each do |d|
      Dir.foreach(d) do |item|
        next if item == '.' or item == '..' or item[-3..-1] != 'csv'
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        
        header_format = Spreadsheet::Format.new(
          :weight => :bold,
          :horizontal_align => :center,
          :bottom => :thin,
          :locked => true
        )
        
        sheet1.row(0).default_format = header_format
        lines = CSV.read d + item, :headers => true, :encoding=>"UTF-8", :col_sep=>","
        lines.to_a.each_with_index do |r, i|
          sheet1.row(i).replace(r)
        end
        book.write(d + 'xls\\' + item.gsub('.csv', '.xls'))
      end
    end
  end
    
  # export 440 auto submodels
  task :i => :environment do
    lines = CSV.read 'utils/峻峰华亭可操作车型 王哲  20130116 亚伟.csv', :headers => true, :encoding=>"GBK", :col_sep=>","
    puts lines.length
    verified_asms = {}
    File.open 'utils\\峻峰华亭可操作车型三级整理 王哲 01302013.csv', 'w:UTF-8' do |f|
      f.puts 'ID,品牌,型号,款式,年代,发动机型号'
      lines.each do |l|
        next if l[10] != '可操作' && l[10] != '未确认'
        asm = AutoSubmodel.find l[0]
        asm.engine_model.gsub!(',',' ') if asm.engine_model
        f.puts "#{asm.id},#{asm.auto_model.auto_brand.name.gsub('/','|')},#{asm.auto_model.name.gsub(',',' ')},#{asm.name.gsub(',',' ')},#{asm.year_range},#{asm.engine_model}"
      end
    end
  end

  # merge duplicated mann models and export all mann models
  task :j => :environment do
    # remove blanks in year_range
    if 1
      t = []
      AutoSubmodel.where(data_source: 0).each do |asm|
        yr = asm.year_range.gsub(/\s+/, '')
        if yr != asm.year_range
          asm.update_attributes year_range: yr
          t << asm
        end
      end
      puts "#{t.count} mann models have blanks"
    end
    
    if 1
      puts AutoSubmodel.where(data_source: 0).count
      to_be_destroyed = []
      AutoSubmodel.where(data_source: 0).group_by {|x| x.auto_model.id.to_s + x.name + x.year_range}.each do |x|
        next if x[1].count < 2
        x[1][1..-1].each do |asm1|
          asm1.orders.each do |o|
            x[1][0].orders << o
          end
          asm1.parts.each do |p|
            x[1][0].parts << p
          end
          to_be_destroyed << asm1  
        end
      end
      puts "to_be_destroyed: #{to_be_destroyed.count}"
      to_be_destroyed.each do |asm|
        asm.destroy
      end
      puts AutoSubmodel.where(data_source: 0).count
    end

  end

  # export mann & longfeng models
  task :k => :environment do
    AutoBrand.each do |ab|
      if ab.auto_models.first.auto_submodels.first.data_source == 0
        file_path = 'utils\\mann\\' + ab.name.gsub('/',' ') + '.csv'
      else
        file_path = 'utils\\longfeng\\' + ab.name.gsub('/',' ') + '.csv'
      end
      File.open file_path, 'w:UTF-8' do |f|
        f.puts 'ID,品牌,型号(系列),型号(英文),款式,排量,制造年代,发动机型号,备注'
        ab.auto_models.asc(:name).each do |am|
          am.auto_submodels.asc(:name).each do |asm|
            asm.engine_model.gsub!(',',' ') if asm.engine_model
            f.puts "#{asm.id},#{ab.name.gsub('/','|')},#{am.name.gsub(',',' ')},,#{asm.name.gsub(',',' ')},#{asm.engine_displacement},#{asm.year_range},#{asm.engine_model},"
          end
        end
      end
    end
  end  

  # export mahle & mann parts in junfeng storehouse
  task :l => :environment do
    
    oil_filter = PartType.find_by name: '机滤'
    puts 'oil_filter not found' or exit if oil_filter.nil?
    air_filter = PartType.find_by name: '空气滤清器'
    puts 'air_filter not found' or exit if air_filter.nil?
    cabin_filter = PartType.find_by name: '空调滤清器'
    puts 'cabin_filter not found' or exit if cabin_filter.nil?

    mann = PartBrand.find_by name: '曼牌 Mann'
    puts 'mann not found' or exit if mann.nil?
    mahle = PartBrand.find_by name: '马勒 '
    puts 'mahle not found' or exit if mahle.nil?

    #mahle_p = Part.find_by(number: 'LA 521')
    #mann_ps = []
    #mahle_p.auto_submodels.each do |asm|
    #  asm.parts.each do |p|
    #    mann_ps << p if p.part_type == mahle_p.part_type and p.part_brand == mann
    #  end
    #end
    #puts mann_ps.uniq!.size
    #exit
    
    sh = Storehouse.find_by name: '北京 峻峰华亭仓库'
    mahle_oil_filters = []
    mahle_air_filters = []
    mahle_cabin_filters = []
    sh.partbatches.each do |pb|
      mahle_oil_filters << pb.part if (pb.part.part_type == oil_filter and pb.part.part_brand == mahle)
      mahle_air_filters << pb.part if (pb.part.part_type == air_filter and pb.part.part_brand == mahle)
      mahle_cabin_filters << pb.part if (pb.part.part_type == cabin_filter and pb.part.part_brand == mahle)
    end
    mahle_oil_filters.uniq!.sort_by!(&:number)
    mahle_air_filters.uniq!.sort_by!(&:number)
    mahle_cabin_filters.uniq!.sort_by!(&:number)
    filters = mahle_oil_filters + mahle_air_filters + mahle_cabin_filters
    File.open '峻峰华亭马勒配件和曼牌匹配 王哲 02102014.csv', 'w:UTF-8' do |f|
      f.puts '配件类型,马勒配件型号,曼牌配件型号1,曼牌配件型号2,曼牌配件型号3,曼牌配件型号4,曼牌配件型号5,曼牌配件型号6,曼牌配件型号7,曼牌配件型号8'
      nil_part = Part.new number: ''
      filters.each do |ff|
        mann_filters = []
        ff.auto_submodels.each do |asm|
          asm.parts.each do |p|
            mann_filters << p if (p.part_type == ff.part_type && p.part_brand == mann)
          end
        end
        mann_filters.uniq!
        puts "too much matched mann filters: #{ff.number}, #{mann_filters.size}" or exit if mann_filters.size > 8
        mann_filters = mann_filters + [nil_part, nil_part, nil_part, nil_part, nil_part, nil_part]
        f.puts "#{ff.part_type.name},#{ff.number},#{mann_filters[0].number},#{mann_filters[1].number},#{mann_filters[2].number},#{mann_filters[3].number},#{mann_filters[4].number},#{mann_filters[5].number}"
      end
    end
  end


end

