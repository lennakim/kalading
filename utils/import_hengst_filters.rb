#encoding: UTF-8
require 'json'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

d = File.open 'hengst_filter.json', 'rb' do |f|
  f.read  
end
hengst_filters = JSON.parse(d)
puts "hengst_filter count #{hengst_filters.count}"

part_type_name_to_name_cn = {
  'AirFilter' => '空气滤清器',
  'OilFilter' => '机滤',
  'FuelFilter' => '燃油滤清器',
  'CabinFilter' => '空调滤清器',
}

response_json = RestClient.get(
                               server_address + 'part_types',
                               :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_types = JSON.parse(response_json)

part_type_cn_to_id = {}
part_types.each do |pt|
  part_type_cn_to_id[pt['name']] = pt['_id']
end

part_type_to_id = {}
part_type_name_to_name_cn.each do |k, v|
  part_type_to_id[k] = part_type_cn_to_id[v]
end
puts JSON.pretty_generate(JSON.parse(part_type_to_id.to_json))

# A cache to save part brand id
part_brand_name_to_id = {}
response_json = RestClient.get(
                               server_address + 'part_brands',
                               :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
part_brands = JSON.parse(response_json)

part_brands.each do |pb|
  part_brand_name_to_id[pb['name']] = pb['_id']
end
puts JSON.pretty_generate(part_brand_name_to_id)

puts "hengst not found" or exit if !part_brand_name_to_id['汉格斯特']

part_number_to_type_id = {}
hengst_filters.each do |f|
  type_id = part_type_to_id[f['type']]
  puts "part_type error #{response_json.code}" or exit if !type_id
  part_number_to_type_id[f['name']] = type_id if !part_number_to_type_id[f['name']]
end
#puts JSON.pretty_generate(part_number_to_type_id)

part_number_to_type_id.each do |number, type_id|
  # 添加配件，设置类型，品牌
  part = {
    :number => number,
    :part_brand_id => part_brand_name_to_id['汉格斯特'],
    :part_type_id => type_id,
    :auto_submodel_ids => []
  }
  response_json = RestClient.post(server_address + 'parts', part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "create part #{p['number']} error #{response_json.code}" or exit if response_json.code != 201
end
