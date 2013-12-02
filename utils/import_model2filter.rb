#encoding: UTF-8
require 'json'
require 'rest_client'

part_brand_name_to_name_cn = {
  'manpai' => '曼牌'
}
part_brand_to_id = {}

part_type_name_to_name_cn = {
  'air_filter' => '空气滤清器',
  'oil_filter' => '机滤',
  'fuel_filter' => '燃油滤清器',
  'cabin_filter' => '空调滤清器',
}
part_type_to_id = {}

auto_triple_to_id = {}

server_address = 'http://127.0.0.1:3000/'

response_json = RestClient.get(
                               server_address + 'part_brands',
                               :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_brands = JSON.parse(response_json)

part_brand_name_cn_to_id = {}
part_brands.each do |pb|
  part_brand_name_cn_to_id[pb['name']] = pb['_id']
end
#puts JSON.pretty_generate(JSON.parse(part_brand_name_cn_to_id.to_json))

part_brand_name_to_name_cn.each do |k, v|
  part_brand_to_id[k] = part_brand_name_cn_to_id[v]
end
#puts JSON.pretty_generate(JSON.parse(part_brand_to_id.to_json))

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
#puts JSON.pretty_generate(JSON.parse(part_type_cn_to_id.to_json))

part_type_name_to_name_cn.each do |k, v|
  part_type_to_id[k] = part_type_cn_to_id[v]
end
#puts JSON.pretty_generate(JSON.parse(part_type_to_id.to_json))

auto_submodel_id_to_parts_ids = {}
part_triple_to_ids = {}
part_id_to_new_infos = {}
auto_submodel_id_to_new_infos = {}

d = File.open 'm2f.txt', 'rb:gbk' do |f|
  f.read  
end

model_to_parts = JSON.parse(d)
model_to_parts.each do |m2p|

  response_json = RestClient.get(
                                server_address + 'auto_submodels?' + 'brand=' + CGI::escape(m2p['brand_name']) + '&model=' + CGI::escape( m2p['series_name']) + '&submodel=' + CGI::escape(m2p['model_name']),
                                :content_type => :json, :accept => :json){|response, request, result| response }
  puts "get auto_submodel error #{response_json.code}" or exit if response_json.code != 200
  #puts JSON.pretty_generate(JSON.parse(response_json))
  auto_submodels = JSON.parse(response_json)
  if auto_submodels.size <= 0
    puts "auto submodel not found: #{m2p['brand_name']} #{m2p['series_name']} #{m2p['model_name']} "
    next
  end
  auto_submodel_id_to_new_infos[auto_submodels[0]['_id']] ||= auto_submodels[0]

  m2p["parts"].each do |p|
    # 添加配件，设置类型，品牌
    unless  part_triple_to_ids[p['type'] + p['brand'] + p['number']]
      part = {
      :number => p['number'],
      :part_brand_id => part_brand_to_id[p['brand']],
      :part_type_id => part_type_to_id[p['type']],
      :auto_submodel_ids => []
      }
      response_json = RestClient.post(server_address + 'parts', part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
      puts "create part error #{response_json.code}" or exit if response_json.code != 201
      part_id = JSON.parse(response_json)['_id']
      part_triple_to_ids[p['type'] + p['brand'] + p['number']] = part_id
      part_id_to_new_infos[part_id] ||= part
#      auto_submodel_id_to_new_infos[auto_submodels[0]['_id']][:part_ids] ||= []
#      auto_submodel_id_to_new_infos[auto_submodels[0]['_id']][:part_ids] << part_id
    end
    part_id_to_new_infos[part_triple_to_ids[p['type'] + p['brand'] + p['number']]][:auto_submodel_ids] << auto_submodels[0]['_id']
  end
end
#puts JSON.pretty_generate(JSON.parse(part_id_to_new_infos.to_json))
#puts JSON.pretty_generate(JSON.parse(auto_submodel_id_to_new_infos.to_json))

part_id_to_new_infos.each do |k ,v|
  response_json = RestClient.put(server_address + 'parts/' + k, v.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "update part error #{response_json.code}" or exit if response_json.code != 204
end

#auto_submodel_id_to_new_infos.each do |k ,v|
#  response_json = RestClient.put(server_address + 'auto_submodels/' + k, v.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
#  puts "update auto submodel error #{response_json.code}" or exit if response_json.code != 204
#end
