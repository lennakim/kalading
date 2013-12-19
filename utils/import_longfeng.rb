#encoding: UTF-8
require 'json'
require 'rest_client'
require 'CSV'

server_address = 'http://127.0.0.1:3000/'

mahle = '马勒 Mahle'
mann = '曼牌 Mann'
sofima = '索菲玛 Sofima'
oil_filter = '机滤'
air_filter = '空气滤清器'
cabin_filter = '空调滤清器'
fuel_filter = '燃油滤清器'


asms = CSV.read 'longfeng.csv', :headers => false, :encoding=>"GBK", :col_sep=>","
#brands = CSV.read 'longfeng_to_kalading_brand.csv', :headers => false, :encoding=>"GBK", :col_sep=>","

puts "auto submodels count #{asms.count}"

asms.each do |asm|
  next if !asm[3] || !asm[4] || !asm[5] || !asm[7]
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
    
  parts << {
    'part_brand_name' => mahle,
    'part_type_name' => oil_filter,
    'number' => asm[17]
  } if asm[17]

  parts << {
    'part_brand_name' => mahle,
    'part_type_name' => fuel_filter,
    'number' => asm[18]
  } if asm[18]

  parts << {
    'part_brand_name' => mahle,
    'part_type_name' => air_filter,
    'number' => asm[19]
  } if asm[19]

  parts << {
    'part_brand_name' => mahle,
    'part_type_name' => cabin_filter,
    'number' => asm[20]
  } if asm[20]

  parts << {
    'part_brand_name' => mahle,
    'part_type_name' => cabin_filter,
    'number' => asm[21]
  } if asm[21]

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => oil_filter,
    'number' => asm[22]
  } if asm[22]

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => fuel_filter,
    'number' => asm[23]
  } if asm[23]

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => air_filter,
    'number' => asm[24]
  } if asm[24]

  if asm[25]
    filters = asm[25].split('/')
    if filters.length == 2 && filters[1].length == 1
      filters = [filters.join('/')]
    end
    filters.each do |f|
      parts << {
        'part_brand_name' => mann,
        'part_type_name' => cabin_filter,
        'number' => f
      }
    end 
  end
  
  parts << {
    'part_brand_name' => sofima,
    'part_type_name' => oil_filter,
    'number' => asm[26]
  } if asm[26]

  parts << {
    'part_brand_name' => sofima,
    'part_type_name' => fuel_filter,
    'number' => asm[27]
  } if asm[27]

  parts << {
    'part_brand_name' => sofima,
    'part_type_name' => air_filter,
    'number' => asm[28]
  } if asm[28]

  parts << {
    'part_brand_name' => sofima,
    'part_type_name' => cabin_filter,
    'number' => asm[29]
  } if asm[29]
  
  data = {
    'brand_name' => asm[3],
    'model_name' => asm[4],
    'submodel_name' => asm[5],
    'engine_model' => asm[6],
    'data_source' => 1,
    'year_range' => asm[7],
    'oil_filter_oe' => asm[8],
    'fuel_filter_oe' => asm[10],
    'air_filter_oe' => asm[12],
    'service_level' => 0,
    'parts' => parts
  }
  
  #puts JSON.pretty_generate(data)
  response_json = RestClient.post(server_address + 'auto_submodels_import', data.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "import error #{response_json.code}\n#{JSON.pretty_generate(data)}" or exit if response_json.code != 204
end
