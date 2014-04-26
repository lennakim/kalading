# encoding: UTF-8

namespace :rename_asm do
  # This must be ran in irb, because 'spreadsheet' is not in Gemfile
  task :a => :environment do
    require 'spreadsheet'
    require 'csv'
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

  # must be ran in irb
  task :c => :environment do
    class String
      def inspect
        ''
      end
    end
    
    class Hash
      def inspect
        ''
      end
    end

    class Array
      def inspect
        ''
      end
    end

    require 'csv'
    require 'json'

    d = File.open 'utils/accessories_write_zf_second.text', 'r:UTF-8' do |f|
      f.read  
    end
    m_models = JSON.parse d
    puts m_models.count
    mann_tuple_to_models = {}
    # 解析曼牌的原始车型数据，产生hash
    m_models.each do |m|
      #{"brand_name"=>"一汽轿车(中国) / FAW", "series_name"=>"CA系列 / CA Series | 82-90", "model_name"=>"1.8L", "engine"=>" JW75", "year"=>"08/88->12/90", 
      # "parts"=> {"type"=>"空气滤清器", "brand"=>"曼牌", "number"=>"C 22 117", "limit"=>[] } {"type"=>"机油滤清器", "brand"=>"曼牌", "number"=>"W 713/16", "limit"=>}{"type"=>"燃油滤清器", "brand"=>"曼牌", "number"=>"WK 834/1", "limit"=> []}
      mann_tuple_to_models[ [m['brand_name'], m['series_name'], m['model_name'] ] ] ||= []
      mann_tuple_to_models[ [m['brand_name'], m['series_name'], m['model_name'] ] ] << m
    end
    puts mann_tuple_to_models.size


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
    # 遍历需要删除的车型数据，从mann_tuple_to_models删除
    to_be_deleted_asms.each do |m|
      mann_tuple_to_models.delete [ m['mann_brand'], m['mann_model'], m['mann_submodel'] ]
    end
    puts "After deleting expired models, mann: #{mann_tuple_to_models.size}"

    # 计算剩余的车型数
    c = mann_tuple_to_models.inject(0) {|sum, x| sum + x[1].size }
    puts "After deleting expired models: #{c}"

    # 改名，增加机油量，机油型号信息
    memo = 0
    memo1 = 0
    mann_tuple_to_models.each do |k, v|
      rename_info = mann_tuple_to_rename_info[k]
      if rename_info
        v.each do |m|
          m['brand_name'] = rename_info['brand']
          m['series_name'] = rename_info['model']
          m['model_name'] = rename_info['submodel']
          m['engine_displacement'] = rename_info['displacement']
          m['year'] = rename_info['year']
          m['operatable'] = rename_info['operatable']
          m['oil_cap'] = rename_info['oil_cap']
          memo1 = memo1 + 1 if rename_info['oil_cap'].to_f != 0.0 
          m['oil1'] = rename_info['oil1']
          m['oil2'] = rename_info['oil2']
          m['oil3'] = rename_info['oil3']
          memo = memo + 1
        end
      else
        v.each do |m|
          a = m['year'].split('->')
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
          m['year'] = start_date + '-' + end_date
          m['series_name'] = m['series_name'].split('/')[0].split('(')[0].split('|')[0].strip
        end
      end
    end
    puts "Matched models: #{memo}"
    puts "Has oil capacity: #{memo1}"
    
    # 输出全部配件信息为JSON文件
    parts = []
    mann_tuple_to_models.each do |k, v|
      v.each do |m|
        m['parts_index'] = parts.size
        parts << m['parts']
      end
    end

    File.open 'mann_parts.json', 'w:UTF-8' do |f|
      f.puts JSON.pretty_generate(parts)
    end
    
    models = []
    mann_tuple_to_models.each do |k, v|
      v.each do |m|
        models << [m['brand_name'], m['series_name'], m['model_name'], m['engine_displacement'], m['year'], m['engine'], k[0], k[1], k[2], m['parts_index'], m['operatable'], m['oil_cap'], m['oil1'], m['oil2'], m['oil3'] ]
      end
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
    sheet1.row(0).replace(['品牌', '型号(系列)', '款式', '排量', '制造年代' , '发动机型号', '曼牌品牌', '曼牌车型', '曼牌名称', '配件信息', '操作性', '机油量', '机油1', '机油2', '机油3'])
    models.each_with_index do |r, i|
      sheet1.row(i + 1).replace(r)
    end
    book.write('mann_models_renamed.xls')
   
    # 人工消除曼牌重复车型
    # 补充排量信息
  end
  
  # 转换曼牌数据为xls，人工检查重复车型
  task :d => :environment do
        d = File.open 'utils/accessories_write_zf_second.text', 'r:UTF-8' do |f|
      f.read  
    end
    m_models = JSON.parse d
    puts m_models.count

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    
    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :bottom => :thin,
      :locked => true
    )

    mann_tuple_to_parts = {}
    m_models.each do |m|
      #{"brand_name"=>"一汽轿车(中国) / FAW", "series_name"=>"CA系列 / CA Series | 82-90", "model_name"=>"1.8L", "engine"=>" JW75", "year"=>"08/88->12/90", 
      # "parts"=> [ {"type"=>"空气滤清器", "brand"=>"曼牌", "number"=>"C 22 117", "limit"=>[] }, {"type"=>"机油滤清器", "brand"=>"曼牌", "number"=>"W 713/16", "limit"=>}, {"type"=>"燃油滤清器", "brand"=>"曼牌", "number"=>"WK 834/1", "limit"=> []} ]
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ] ||= []
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ].concat m['parts']
      mann_tuple_to_parts[ [m['brand_name'], m['series_name'], m['model_name'], m['year'], m['engine'] ] ].uniq!
    end
    puts mann_tuple_to_parts.count
    
    sheet1.row(0).default_format = header_format
    sheet1.row(0).replace ['品牌', '型号(系列)', '款式', '制造年代' , '发动机型号', '机油滤清器1', '机油滤清器2', '机油滤清器3', '机油滤清器4', '空气滤清器1', '空气滤清器2', '空调滤清器1', '空调滤清器2', '空调滤清器3', '空调滤清器4', '燃油滤清器1', '燃油滤清器2']
    mann_tuple_to_parts.each_with_index do | (k, v), i|
      part_type_to_number = v.group_by {|x| x['type'] }
      part_type_to_number['机油滤清器'] ||= []
      part_type_to_number['空气滤清器'] ||= []
      part_type_to_number['空调滤清器'] ||= []
      part_type_to_number['燃油滤清器'] ||= []
      puts "Too much engine oil for #{k}, #{v} " or exit if part_type_to_number['机油滤清器'].size > 4
      puts "Too much engine oil for #{k}, #{v} " or exit if part_type_to_number['空气滤清器'].size > 2
      puts "Too much engine oil for #{k}, #{v} " or exit if part_type_to_number['空调滤清器'].size > 4
      puts "Too much engine oil for #{k}, #{v} " or exit if part_type_to_number['燃油滤清器'].size > 2
      a = [k[0], k[1], k[2], k[3], k[4]]
      a.concat [part_type_to_number['机油滤清器'][0] || '', part_type_to_number['机油滤清器'][1] || '', part_type_to_number['机油滤清器'][2] || '', part_type_to_number['机油滤清器'][3] || '' ]
      a.concat [part_type_to_number['空气滤清器'][0] || '', part_type_to_number['空气滤清器'][1] || '' ]
      a.concat [part_type_to_number['空调滤清器'][0] || '', part_type_to_number['空调滤清器'][1] || '', part_type_to_number['空调滤清器'][2] || '', part_type_to_number['空调滤清器'][3] || '' ]
      a.concat [part_type_to_number['燃油滤清器'][0] || '', part_type_to_number['燃油滤清器'][1] || '' ]
      sheet1.row(i + 1).replace(a)
    end
    book.write('mann_models_and_parts.xls')
  end

end