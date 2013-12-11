#encoding: UTF-8
require 'json'
require 'rest_client'
require 'CSV'

server_address = 'http://127.0.0.1:3000/'

asms = CSV.read 'longfeng.csv', :headers => false, :encoding=>"GBK", :col_sep=>","
brands = CSV.read '卡拉丁汽车品牌列表.csv', :headers => false, :encoding=>"GBK", :col_sep=>","

puts "auto submodels count #{asms.count}"

def longfeng_to_kalading()
end

puts brands[0]

asms.first(11).each do |asm|
  puts 'brand: ' + asm[3]
  puts 'model: ' + asm[4]
  puts 'submodel: ' + asm[5]
  puts 'engine model: ' + asm[6]
  puts 'year range: ' + asm[7]
  puts 'oil filter OE: ' + asm[8]
  puts 'LAMA oil filter: ' + asm[9]
  puts 'fuel filter OE: ' + asm[10]
  puts 'LAMA fuel filter: ' + asm[11]
  puts 'air filter OE: ' + asm[12]
  puts 'LAMA air filter: ' + asm[13]
  puts 'cabin filter OE: ' + asm[14]
  puts 'LAMA cabin filter: ' + asm[15]
  puts 'LAMA cabin filter: ' + asm[16]
  puts 'Mahle oil filter: ' + asm[17] if asm[17]
  puts 'Mahle fuel filter: ' + asm[18] if asm[18]
  puts 'Mahle air filter: ' + asm[19] if asm[19]
  puts 'Mahle cabin filter: ' + asm[20] if asm[20]
  puts 'Mahle cabin filter: ' + asm[21] if asm[21]
  puts 'Mann oil filter: ' + asm[22] if asm[22]
  puts 'Mann fuel filter: ' + asm[23] if asm[23]
  puts 'Mann air filter: ' + asm[24] if asm[24]
  puts 'Mann cabin filter: ' + asm[25] if asm[25]
  puts 'Sofima oil filter: ' + asm[26] if asm[26]
  puts 'Sofima fuel filter: ' + asm[27] if asm[27]
  puts 'Sofima air filter: ' + asm[28] if asm[28]
  puts 'Sofima cabin filter: ' + asm[29] if asm[29]
  parts = []
  #parts << {
  #  'part_brand_name' => castrol,
  #  'part_type_name' => '机油',
  #  'number' => fn
  #} 
  data = {
    'service_level' => asm[5].to_i,
    'motoroil_cap' => asm[2].to_i,
    'parts' => parts
  }
  #puts JSON.pretty_generate(data)
  #response_json = RestClient.post(server_address + 'auto_submodels_import_by_id/' + asm[0], data.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  #puts "import error #{response_json.code}\n#{JSON.pretty_generate(data)}" or exit if response_json.code != 204
end
