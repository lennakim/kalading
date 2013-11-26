#encoding: UTF-8
require 'json'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

mann = '曼牌 Mann'
part_type_name_to_name_cn = {
  'air_filter' => '空气滤清器',
  'oil_filter' => '机滤',
  'fuel_filter' => '燃油滤清器',
  'cabin_filter' => '空调滤清器',
}

d = File.open 'm_models.json', 'rb' do |f|
  f.read  
end
m_models = JSON.parse(d)
puts "m_model count #{m_models.count}"

m_models.each do |m|
  parts = []
  parts << {
    'part_brand_name' => mann,
    'part_type_name' => part_type_name_to_name_cn['air_filter'],
    'number' => m['air_filter']
  } if m['air_filter'] != ''

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => part_type_name_to_name_cn['oil_filter'],
    'number' => m['oil_filter']
  } if m['oil_filter'] != ''

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => part_type_name_to_name_cn['fuel_filter'],
    'number' => m['fuel_filter']
  } if m['fuel_filter'] != ''

  parts << {
    'part_brand_name' => mann,
    'part_type_name' => part_type_name_to_name_cn['cabin_filter'],
    'number' => m['cabin_filter']
  } if m['cabin_filter'] != ''

  data = {
    'brand_name' => m['manufacturer'],
    'model_name' => m['series'],
    'submodel_name' => m['model'],
    'submodel_name' => m['model'],
    'engine_model' => m['engine'],
    'year' => m['year'],
    'parts' => parts
  }
  #puts JSON.pretty_generate(data)
  response_json = RestClient.post(server_address + 'auto_submodels_import', data.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "import error #{response_json.code}\n#{JSON.pretty_generate(m)}\n#{JSON.pretty_generate(data)}" or exit if response_json.code != 204
end
