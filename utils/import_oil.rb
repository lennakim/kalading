#encoding: UTF-8
#require 'mysql2'
require 'json'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

#client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root",:password=>"anycomm",:database=>"car")
#ah_models = client.query("select * from ah_model", :as => :array)
#ah_jiyous = client.query("select * from ah_jiyou")
#ah_model_jiyous = client.query("select * from ah_model_jiyou")

d = File.open 'ah_models.json', 'rb' do |f|
  f.read  
end
ah_models = JSON.parse(d)
puts "model count #{ah_models.count}"

d = File.open 'ah_jiyous.json', 'rb' do |f|
  f.read  
end
ah_jiyous = JSON.parse(d)
puts "oil count #{ah_jiyous.count}"

d = File.open 'ah_model_jiyous.json', 'rb' do |f|
  f.read  
end
ah_model_jiyous = JSON.parse(d)
puts "model->oil count #{ah_model_jiyous.count}"
#puts JSON.pretty_generate(ah_model_jiyous)

# Firstly, make a map from auto submodel to parts:
# {'brand_name' => n, 'series_name' => n, 'model_name' => n} => [{ 'brand_name' => n, 'number' => n, 'capacity' => n},...]
auto_submodel_to_parts = {}

model_code_to_jiyou_codes = {}
ah_model_jiyous.each do |mj|
  model_code_to_jiyou_codes[mj['model_code']] ||= []
  model_code_to_jiyou_codes[mj['model_code']] << mj['jiyou_code']
end

model_without_oil_count = 0
ah_models.each do |m|
  auto_submodel_to_parts[{
    'brand_name' => m['brand_name'],
    'series_name' => m['series_name'],
    'model_name' => m['model_name']
  }] = []

  if !model_code_to_jiyou_codes[m['model_code']]
    model_without_oil_count += 1
    next 
  end
  
  model_code_to_jiyou_codes[m['model_code']].each do |jc|
    jiyou = ah_jiyous.select {|a| a['code'] == jc}[0]
    puts "jiyou code #{jc}  not found" or exit if !jiyou
    part = { 'brand_name' => jiyou['brand_name'], 'number' => jiyou['name'], 'capacity' => jiyou['name'].split.last.scan(/\d+/).first.to_i }
    auto_submodel_to_parts[{
      'brand_name' => m['brand_name'],
      'series_name' => m['series_name'],
      'model_name' => m['model_name']
    }] << part
  end
  #puts JSON.pretty_generate(model_to_parts)
end
puts "Analyzing auto models done, #{model_without_oil_count} models have not oil matched"

# A cache to save auto_submodel id
auto_submodel_to_id = {}

response_json = RestClient.get(
                               server_address + 'part_types',
                               :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_types = JSON.parse(response_json)

part_type = part_types.select {|a| a['name'] == '机油'}[0]
puts "jiyou id not found" or exit if !part_type
puts "jiyou id is #{part_type['_id']}"

# A cache to save part brand id
part_brand_name_to_id = {}
response_json = RestClient.get(
                               server_address + 'part_brands',
                               :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_brands = JSON.parse(response_json)

part_brands.each do |pb|
  part_brand_name_to_id[pb['name']] = pb['_id']
end
#puts JSON.pretty_generate(part_brand_name_to_id)

auto_submodel_id_to_parts_ids = {}
part_info_to_ids = {}
part_id_to_new_infos = {}
auto_submodel_id_to_new_infos = {}

auto_submodel_to_parts.each do |m, parts|

  response_json = RestClient.get(
                                 server_address + 'auto_submodels?' + 'brand=' + CGI::escape(m['brand_name']) + '&model=' + CGI::escape( m['series_name']) + '&submodel=' + CGI::escape(m['model_name']),
                                 :content_type => :json, :accept => :json){|response, request, result| response }
  puts "get auto_submodel error #{response_json.code}" or exit if response_json.code != 200
  #puts JSON.pretty_generate(JSON.parse(response_json))
  auto_submodels = JSON.parse(response_json)
  if auto_submodels.size <= 0
    puts "auto submodel not found: #{m['brand_name']} #{m['series_name']} #{m['model_name']} " or next
  end
  
  auto_submodel_id_to_new_infos[auto_submodels[0]['_id']] ||= auto_submodels[0]

  parts.each do |p|
    # 添加配件，设置或创建类型，品牌
    unless  part_info_to_ids[p['brand_name'] + p['number']]
      unless part_brand_name_to_id[p['brand_name']]
        part_brand = {
          :name => p['brand_name']
        }
        response_json = RestClient.post(server_address + 'part_brands', part_brand.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
        puts "create part brand #{p['brand_name']} error #{response_json.code}" or exit if response_json.code != 201
        part_brand_name_to_id[p['brand_name']] = JSON.parse(response_json)['_id']
      end

      part = {
        :number => p['number'],
        :capacity => p['capacity'],
        :part_brand_id => part_brand_name_to_id[p['brand_name']],
        :part_type_id => part_type['_id'],
        :auto_submodel_ids => []
      }
      response_json = RestClient.post(server_address + 'parts', part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
      puts "create part #{p['number']} error #{response_json.code}" or exit if response_json.code != 201
      part_id = JSON.parse(response_json)['_id']
      part_info_to_ids[p['brand_name'] + p['number']] = part_id
      part_id_to_new_infos[part_id] ||= part
    end
    part_id_to_new_infos[part_info_to_ids[p['brand_name'] + p['number']]][:auto_submodel_ids] << auto_submodels[0]['_id']
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
