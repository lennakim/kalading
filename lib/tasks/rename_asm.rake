# encoding: UTF-8

namespace :rename_asm do
  task :a => :environment do
    Spreadsheet.client_encoding = 'GBK'
    File.open 'deleted_asms.csv', 'w:UTF-8' do |deleted_f|
      deleted_f.puts 'ID,品牌,型号(系列),款式,排量,制造年代,备注'
      File.open 'renamed_asms.csv', 'w:UTF-8' do |renamed_f|
        renamed_f.puts 'ID,品牌,型号(系列),款式,排量,制造年代,备注'
        Dir.glob('./utils/renamed/**/*.xls*') do |f|
          begin
            #puts "Processing #{f}"
            book = Spreadsheet.open f
            sheet1 = book.worksheet 0
            sheet1.each 1 do |row|
              #puts "#{f},#{row[0]},#{row[1]},#{row[8]}"
              if row[8].to_i == 1
                deleted_f.puts "#{row[0]},#{row[1]},#{row[2]},#{row[4]},#{row[5]},#{row[6]},#{row[8]}"
              else
                renamed_f.puts "#{row[0]},#{row[1]},#{row[2]},#{row[4]},#{row[5]},#{row[6]},#{row[8]}"
              end
            end
          rescue
            puts "Error occured while processing #{f}"
          end
        end
      end
    end
  end
  
  # 读取车型的原始曼牌名称
  task :b => :environment do
    lines = CSV.read 'oil_liyawei.csv', :headers => true, :encoding=>"GBK", :col_sep=>","
    asm_id_to_oil_cap = {}
    lines.each do |l|
      asm_id_to_oil_cap[l[0]] = [l[6] || l[7], l[8], l[9], l[10], l[11]]
    end
    
    #File.open 'renamed_asms_with_mann_name.csv', 'w:UTF-8' do |f|
    #  f.puts 'ID,品牌,型号(系列),款式,排量,制造年代,备注,曼牌品牌,曼牌车型,曼牌名称,可操作性,机油容量,机油1,机油2,机油3'
    #  lines = CSV.read 'renamed_asms.csv', :headers => false, :encoding=>"UTF-8", :col_sep=>","
    #  puts "To be renamed auto submodels number: #{lines.count}"
    #  lines.each do |l|
    #    asm = AutoSubmodel.find l[0]
    #    if asm.nil?
    #      puts "#{l[0]}, #{l[1]}, #{l[2]}, #{l[3]} not found"
    #      next
    #    end
    #    extras = ',,,'
    #    item = asm_id_to_oil_cap[l[0]]
    #    if item
    #      extras = "#{item[1]},#{item[0]},#{item[2]},#{item[3]}"
    #    end
    #    f.puts "#{l[0]},#{l[1]},#{l[2]},#{l[3]},#{l[4]},#{l[5]},#{l[6]},#{asm.auto_model.auto_brand.name_mann},#{asm.auto_model.name_mann},#{asm.name_mann},#{extras}"
    #  end
    #end

    def collect_mann_name(csv_name, json_name, asm_id_to_oil_cap)
      asms_with_mann_name = []
      lines = CSV.read csv_name, :headers => false, :encoding=>"UTF-8", :col_sep=>","
      puts "#{csv_name} auto submodels number: #{lines.count}"
      lines.each do |l|
        asm = AutoSubmodel.find l[0]
        if asm.nil?
          puts "#{l[0]}, #{l[1]}, #{l[2]}, #{l[3]} not found"
          next
        end
        operatable, oil_cap, oil1, oil2, oil3 = '', '', '', '', ''
        item = asm_id_to_oil_cap[l[0]]
        if item
          operatable, oil_cap, oil1, oil2, oil3 = item[1], item[0], item[2], item[3], item[4]
        end
        asms_with_mann_name <<
          {
          id: l[0],
          brand: l[1],
          model: l[2],
          submodel: l[3],
          displacement: l[4],
          year: l[5],
          comment: l[6],
          mann_brand: asm.auto_model.auto_brand.name_mann,
          mann_model: asm.auto_model.name_mann,
          mann_submodel: asm.name_mann,
          operatable: operatable,
          oil_cap: oil_cap,
          oil1: oil1,
          oil2: oil2,
          oil3: oil3
          }
        File.open json_name, 'w:UTF-8' do |f|
          f.puts JSON.pretty_generate(asms_with_mann_name)
        end
      end
    end
    collect_mann_name 'renamed_asms.csv', 'renamed_asms_with_mann_name.json', asm_id_to_oil_cap
    collect_mann_name 'deleted_asms.csv', 'deleted_asms_with_mann_name.json', asm_id_to_oil_cap
  end

  # 根据曼牌数据产生车型配件数据表
  task :d => :environment do
    class Array
      def inspect
        ''
      end
    end
    require 'json'
    require 'spreadsheet'

    
    d = File.open 'utils/accessories_write_zf_second.text', 'r:UTF-8' do |f|
      f.read  
    end
    m_models = JSON.parse d
    puts m_models.count

    mann_tuple_to_parts = {}
    # 识别曼牌的原始数据重复的车型
    m_models.each do |m|
      #{"brand_name"=>"一汽轿车(中国) / FAW", "series_name"=>"CA系列 / CA Series | 82-90", "model_name"=>"1.8L", "engine"=>" JW75", "year"=>"08/88->12/90", 
      # "parts"=> [ {"type"=>"空气滤清器", "brand"=>"曼牌", "number"=>"C 22 117", "limit"=>[] }, {"type"=>"机油滤清器", "brand"=>"曼牌", "number"=>"W 713/16", "limit"=>}, {"type"=>"燃油滤清器", "brand"=>"曼牌", "number"=>"WK 834/1", "limit"=> []} ]
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ] ||= []
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ].concat m['parts']
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ].uniq!
    end
    puts mann_tuple_to_parts.count
    
    d = File.open 'renamed_asms_with_mann_name.json', 'r:UTF-8' do |f|
      f.read  
    end
    renamed_asms = JSON.parse d
    puts "To be renamed auto submodels number: #{renamed_asms.count}"
    mann_tuple_to_rename_info = {}
    # 遍历整理过名字的车型数据，产生hash
    renamed_asms.each do |m|
      mann_tuple_to_rename_info[ [ m['mann_brand'], m['mann_model'], m['mann_submodel'] ] ] = m
    end
    puts "To be renamed names #{mann_tuple_to_rename_info.size}"

    d = File.open 'deleted_asms_with_mann_name.json', 'r:UTF-8' do |f|
      f.read  
    end
    to_be_deleted_asms = JSON.parse d
    puts "To be deleted auto submodels number: #{to_be_deleted_asms.count}"
    # 对需要删除的车型数据产生hash
    mann_tuple_to_be_delete  = to_be_deleted_asms.group_by do |m|
      [ m['mann_brand'], m['mann_model'], m['mann_submodel'] ]
    end

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :bottom => :thin,
      :locked => true
    )
    sheet1.row(0).default_format = header_format
    sheet1.row(0).replace ['品牌', '型号(系列)', '款式', '排量', '制造年代', '机油量', '机油1', '机油2', '机油3', '曼牌品牌', '曼牌系列', '曼牌款式', '曼牌制造年代' , '发动机型号', '机油滤清器1', '规则', '机油滤清器2', '规则', '机油滤清器3', '规则', '机油滤清器4', '规则', '空气滤清器1', '规则', '空气滤清器2', '规则', '空气滤清器3', '规则', '空气滤清器4', '规则', '空调滤清器1', '规则', '空调滤清器2', '规则', '空调滤清器3', '规则', '空调滤清器4', '规则', '空调滤清器5', '规则', '燃油滤清器1', '规则', '燃油滤清器2', '规则', '燃油滤清器3', '规则', '燃油滤清器4', '规则']
    memo = memo1 = memo2 = memo3 = 0
    i = 1
    mann_tuple_to_parts.each do |k, v|
      # 删除车型
      if mann_tuple_to_be_delete[ [k[0], k[1], k[2]] ]
        memo2 = memo2 + 1
        next
      end

      # 改名，增加机油量信息
      rename_info = mann_tuple_to_rename_info[ [k[0], k[1], k[2]] ]
      if rename_info
        brand = rename_info['brand']
        model = rename_info['model']
        submodel = rename_info['submodel']
        engine_displacement = rename_info['displacement']
        operatable = rename_info['operatable']
        oil_cap = rename_info['oil_cap']
        oil1 = rename_info['oil1'].to_s.delete('?')
        oil2 = rename_info['oil2'].to_s.delete('?')
        oil3 = rename_info['oil3'].to_s.delete('?')
        memo1 = memo1 + 1 if rename_info['oil_cap'].to_f != 0.0 
        memo = memo + 1
      else
        brand = k[0].split('/')[0].strip
        model = k[1].split('/')[0].split('(')[0].split('|')[0].strip
        submodel = k[2]
        engine_displacement = ''
        operatable = ''
        oil_cap = ''
        oil1 = ''
        oil2 = ''
        oil3 = ''
      end

      # 转换制造年代
      a = k[3].split('->')
      start_year = a[0].split('/')[1]
      if start_year > '14'
        start_date = '19' + start_year + '.' + a[0].split('/')[0]
      else
        start_date = '20' + start_year + '.' + a[0].split('/')[0]
      end
      
      end_date = '2014'
      if a[1]
        end_year = a[1].split('/')[1]
        if end_year > '14'
          end_date = '19' + end_year + '.' + a[1].split('/')[0]
        else
          end_date = '20' + end_year + '.' + a[1].split('/')[0]
        end
      end
      if end_date[0..3] <= '2001'
        memo3 = memo3 + 1
        next
      end
      year = start_date + '-' + end_date
    
      a = [brand, model, submodel, engine_displacement, year, oil_cap, oil1, oil2, oil3, k[0], k[1], k[2], k[3], k[4]]
      parts = v.group_by {|x| x['type'] }
      types = ['机油滤清器', '空气滤清器', '空调滤清器', '燃油滤清器']
      types.each do |t|
        parts[t] ||= []
        if t == '空调滤清器'
          puts "Too much #{t} for #{k}, #{parts[t]} " or exit if parts[t].size > 5
          for j in 0..4
            parts[t][j] ||= {'number' =>'', 'limit' => [''] }
            a << parts[t][j]['number'] << parts[t][j]['limit'].join(', ')
          end
        else
          puts "Too much #{t} for #{k}, #{parts[t]} " or exit if parts[t].size > 4
          for j in 0..3
            parts[t][j] ||= {'number' =>'', 'limit' => [''] }
            a << parts[t][j]['number'] << parts[t][j]['limit'].join(', ')
          end
        end
      end
      sheet1.row(i).replace(a)
      i = i + 1
    end
    book.write('mann_models_and_parts.xls')
    puts "Renamed models: #{memo}"
    puts "Removed models: #{memo2}"
    puts "Removed old models: #{memo3}"
    puts "Has oil capacity: #{memo1}"
    # 月份不同，发动机不同，配件相同
    # 月份相同，发动机不同，配件不同
    # 月份相同，发动机不同，配件相同
  end

  task :e => :environment do
    I18n.locale = 'zh-CN'
    oil_filter_type = PartType.find_by name: I18n.t(:oil_filter)
    puts "oil filter type not found" or exit if oil_filter_type.nil?
    engine_oil_type = PartType.find_by name: I18n.t(:engine_oil)
    puts "engine_oil_type not found" or exit if engine_oil_type.nil?
    cabin_filter_type = PartType.find_by name: I18n.t(:cabin_filter)
    puts "cabin_filter_type not found" or exit if cabin_filter_type.nil?
    air_filter_type = PartType.find_by name: I18n.t(:air_filter)
    puts "air_filter_type not found" or exit if air_filter_type.nil?
    fuel_filter_type = PartType.find_by name: I18n.t(:fuel_filter)
    puts "fuel_filter_type not found" or exit if fuel_filter_type.nil?
    mann = PartBrand.find_by name: I18n.t(:mann)
    puts 'mann not found' or exit if mann.nil?

    book = Spreadsheet.open 'mann_models_and_parts.xls'
    sheet1 = book.worksheet 0
    sheet1.each 1 do |row|
      ab = AutoBrand.where( name: row[0].gsub(/\s+/, ''), data_source: 2 ).first_or_create!
      ab.update_attributes name_mann: row[9]
      puts 'ab create failed' or exit if ab.nil?
      am = AutoModel.where( name: row[1].gsub(/\s+/, ''), auto_brand: ab, data_source: 2 ).first_or_create!
      am.update_attributes name_mann: row[10]
      puts 'am create failed' or exit if am.nil?
      asm = AutoSubmodel.where( name_mann: row[11].gsub(/\s+/, ''),
        name: row[2].to_s.gsub(/\s+/, ''),
        year_mann: row[12],
        auto_model: am,
        engine_model: row[13],
        year_range: row[4],
        engine_displacement: row[3],
        data_source: 2,
        motoroil_cap: row[5] ? row[5] : 5.0 ).first_or_create!
      puts 'asm create failed' or exit if asm.nil?
      full_name = row[0].gsub(/\s+/, '') + ' ' + row[1].gsub(/\s+/, '') + ' ' + row[2].to_s.gsub(/\s+/, '') + ' ' + row[3].strip + ' ' + row[4]
      asm.update_attributes full_name: full_name, full_name_pinyin: PinYin.of_string(full_name.gsub(/\s+/, "")).join.gsub(/zhang/, 'chang')

      # Engine oil
      row[6..8].each do |spec|
        next if spec.nil?
        oils = Part.where number: /.*#{spec.gsub(/\s+/, "").split('').join(".*")}.*/i, part_type: engine_oil_type
        puts "#{spec} oil not found" or exit if oils.empty?
        oils.each do |p|
          p.auto_submodels << asm
          asm.parts << p
        end
      end
      
      search_and_add_part_to_asm = Proc.new do |number, t, asm, rule|
        matches = Part.where number: /.*#{number.gsub(/\s+/, "").split('').join(".*")}.*/i, part_brand: mann, part_type: t
        puts "#{number} not found" or exit if matches.empty?
        len_matched = matches.select {|x| x.number.gsub(/\s+/, "").size == number.gsub(/\s+/, "").size }
        puts "#{number} length not found" or exit if len_matched.empty?
        if len_matched.size > 1
          puts "#{number} length too much matched, merging"
          len_matched[1..-1].each do |p|
            p.urlinfos.each do |x|
              len_matched[0].urlinfos << x
            end
            p.auto_submodels.each do |x|
              len_matched[0].auto_submodels << x
            end
            p.partbatches.each do |x|
              len_matched[0].partbatches << x
            end
            p.orders.each do |x|
              len_matched[0].orders << x
            end
            if p.price.to_f != 0.0
              len_matched[0].price = p.price
            end
            p.destroy
          end
        end
        asm.parts << len_matched[0]
        if rule
          asm.part_rules << PartRule.new(text: rule, number: len_matched[0].number)
        end
      end

      # Oil filter
      row[14..21].each_slice(2) do |number, rule|
        next if number.nil?
        search_and_add_part_to_asm.call number, oil_filter_type, asm, rule
      end

      # Air filter
      row[22..29].each_slice(2) do |number, rule|
        next if number.nil?
        search_and_add_part_to_asm.call number, air_filter_type, asm, rule
      end

      # Cabin filter
      row[30..39].each_slice(2) do |number, rule|
        next if number.nil?
        search_and_add_part_to_asm.call number, cabin_filter_type, asm, rule
      end

      # Fuel filter
      row[40..47].each_slice(2) do |number, rule|
        next if number.nil?
        search_and_add_part_to_asm.call number, fuel_filter_type, asm, rule
      end
    end
  end

  # Export all maintainable auto models
  task :f => :environment do
    I18n.locale = 'zh-CN'
    oil_filter_type = PartType.find_by name: I18n.t(:oil_filter)
    puts "oil filter type not found" or exit if oil_filter_type.nil?
    engine_oil_type = PartType.find_by name: I18n.t(:engine_oil)
    puts "engine_oil_type not found" or exit if engine_oil_type.nil?
    cabin_filter_type = PartType.find_by name: I18n.t(:cabin_filter)
    puts "cabin_filter_type not found" or exit if cabin_filter_type.nil?
    air_filter_type = PartType.find_by name: I18n.t(:air_filter)
    puts "air_filter_type not found" or exit if air_filter_type.nil?

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :bottom => :thin,
      :locked => true
    )
    sheet1.row(0).default_format = header_format
    sheet1.row(0).replace ['ID', '品牌/型号(系列)/款式/排量/制造年代', '机油量', '机滤品牌', '机滤型号','空滤品牌', '空滤型号', '空调滤品牌', '空调滤型号']
    i = 1
    AutoSubmodel.where(data_source: 2).asc(:full_name_pinyin).each do |asm|
      oil_filter = asm.parts.find_by part_type: oil_filter_type
      next if oil_filter.nil?
      air_filter = asm.parts.find_by part_type: air_filter_type
      next if air_filter.nil?
      cabin_filter = asm.parts.find_by part_type: cabin_filter_type
      next if cabin_filter.nil?
      a = [asm.id.to_s, asm.full_name, asm.motoroil_cap, oil_filter.part_brand.name, oil_filter.number, air_filter.part_brand.name, air_filter.number, cabin_filter.part_brand.name, cabin_filter.number]
      sheet1.row(i).replace(a)
      i = i + 1
    end
    book.write('可保养车型列表 王哲 03172014.xls')
  end
  
    # Export all auto models
  task :g => :environment do
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :bottom => :thin,
      :locked => true
    )
    sheet1.row(0).default_format = header_format
    sheet1.row(0).replace ['品牌/型号(系列)']
    i = 1
    AutoModel.where(data_source: 2).sort_by(&:full_name).each do |am|
      a = [am.full_name]
      sheet1.row(i).replace(a)
      i = i + 1
    end
    book.write('车型系列列表 王哲 03182014.xls')
  end
  
  task :h => :environment do
    I18n.locale = 'zh-CN'
    AutoSubmodel.any_of({data_source: 2}, {data_source: 3}, {data_source: 4}).each do |asm|
      asm.sum_sanlv_store
    end
  end

  task :i => :environment do
    I18n.locale = 'zh-CN'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :bottom => :thin,
      :locked => true
    )
    sheet1.row(0).default_format = header_format
    sheet1.row(0).replace ['品牌/型号(系列)/年款', '机油档次', '配件类型', '配件型号', '配件价格', '配件类型', '配件型号', '配件价格', '配件类型', '配件型号', '配件价格', '配件类型', '配件型号', '配件价格', '配件类型', '配件型号', '配件价格', '配件类型', '配件型号', '配件价格']
    AutoSubmodel.where(data_source: 2, service_level: 1).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).asc(:full_name_pinyin).each_with_index do |asm, i|
      a = [asm.full_name, asm.motoroil_group.name]
      asm.parts_by_type.each do |t, parts|
        next if t.name == I18n.t(:engine_oil)
        parts.each do |p|
          a += [t.name, p.brand_and_number, p.ref_price] 
        end
      end
      sheet1.row(i + 1).replace(a)
    end
    book.write('可保养车型列表 王哲 03292014.xls')
  end

  task :order_counter => :environment do
    a = Order.not_in(:state => [1,8,9]).group_by {|x|x.car_location+x.car_num}
    a = a.select{|k, v| k.size > 3}.sort_by {|k,v| -v.count }
    File.open '1.csv', 'w:UTF-8' do |f|
      f.puts '车牌号,保养次数'
      a.each do |k,v|
        f.puts "#{k},#{v.size}"
      end
    end
  end

  task :order_counter_by_car_num => :environment do
    ut1 = UserType.find_by name: /中进/
    ut2 = UserType.find_by name: /良好/
    a = Order.not_in(:state => [1,8,9], :user_type => [ut1, ut2]).group_by {|x|x.car_location+x.car_num}
    a = a.select{|k, v| k.size > 3 && k != '京123456'}.sort_by {|k,v| -v.count }
    puts "车牌号数：#{a.size}"
    File.open 'tmp/车牌号和购买服务次数.csv', 'w:UTF-8' do |f|
      f.puts '车牌号,购买次数'
      a.each do |k,v|
        f.puts "#{k},#{v.size}"
      end
    end
  end

  task :asm_stats => :environment do
    ut1 = UserType.find_by name: /中进/
    ut2 = UserType.find_by name: /良好/
    a = AutoSubmodel.all.select {|x| x.orders.not_in(:state => [1,8,9], :user_type => [ut1, ut2]).exists?}.sort_by {|x| -x.orders.size}
    puts "服务车型数：#{a.count}"
    (0..9).each do |i|
      puts "车型：#{a[i].full_name}，保养次数：#{a[i].orders.count}"
    end
  end

  task :order_count => :environment do
    ut1 = UserType.find_by name: /中进/
    ut2 = UserType.find_by name: /良好/
    orders = Order.not_in(:state => [1,8,9], :user_type => [ut1, ut2])
    puts "个人客户有效订单数：#{orders.count}"
    puts "保养订单数：#{orders.select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    puts "单换PM2.5空调滤芯订单数：#{orders.select {|x| x.service_types.count == 1 && x.service_types.first.name == '单换PM2.5空调滤'}.count}"
  end

  task :order_price_stats => :environment do
    ut1 = UserType.find_by name: /中进/
    ut2 = UserType.find_by name: /良好/
    orders = Order.not_in(:state => [1,8,9], :user_type => [ut1, ut2])
    orders.each do |o|
      o.update_attribute :price, o.calc_price
    end
    maintain_orders = orders.select {|x| x.service_types.find_by(name: '换机油机滤')}
    puts "保养订单数：#{maintain_orders.count}"
    puts "保养订单平均价格：#{(maintain_orders.sum{|x| x.price.to_f} / maintain_orders.count).round(1)}"
    puts "价格150元以下(含)保养订单数：#{orders.where(:price.lte => Money.new(15000)).select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    puts "价格150元-400元保养订单数：#{orders.where(:price.gte => Money.new(15000), :price.lt => Money.new(40000)).select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    puts "价格400元-600元保养订单数：#{orders.where(:price.gte => Money.new(40000), :price.lt => Money.new(60000)).select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    puts "价格600元-800元保养订单数：#{orders.where(:price.gte => Money.new(60000), :price.lt => Money.new(80000)).select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    puts "价格800元以上保养订单数：#{orders.where(:price.gte => Money.new(80000)).select {|x| x.service_types.find_by(name: '换机油机滤')}.count}"
    day1 = DateTime.parse("2014-01-01 00:00")
    (1..9).each do |m|
      a = orders.where(:serve_datetime.gte => (m - 1).month.since(day1), :serve_datetime.lt => m.month.since(day1), :price.gt => Money.new(15000) ).select {|x| x.service_types.find_by(name: '换机油机滤')}
      puts "#{m}月份非自带配件保养订单：#{a.count}个，均价：#{(a.sum{|x| x.price.to_f} / a.count).round(1)}"
    end
  end

  task :car_num_stats => :environment do
    ut1 = UserType.find_by name: /中进/
    ut2 = UserType.find_by name: /良好/
    day1 = DateTime.parse("2014-03-31 00:00")
    orders = Order.not_in(:state => [1,8,9], :user_type => [ut1, ut2])
    a = orders.where(:serve_datetime.lte => day1).select {|x| x.service_types.find_by(name: '换机油机滤')}.group_by {|x| [x.car_location, x.car_num] }
    a = a.select{|k, v| k[0].size + k[1].size > 3 && k != ['京', '123456']}.sort_by {|k,v| 0 - orders.where(car_location: k[0], car_num: k[1]).count }
    puts "3月31日前用户个数：#{a.count}"
    File.open 'tmp/3月31日前个人客户购买保养服务次数.csv', 'w:UTF-8' do |f|
      f.puts '车牌号,服务次数'
      a.each do |k, v|
        f.puts "#{k[0] + k[1]},#{orders.where(car_location: k[0], car_num: k[1]).count}"
      end
    end
  end
  
  task :stats_all => [:order_counter, :order_counter_by_car_num, :asm_stats, :order_count, :order_price_stats, :car_num_stats]
end
