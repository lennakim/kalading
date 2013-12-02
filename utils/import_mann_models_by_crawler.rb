#encoding: UTF-8
require 'json'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'
mann = '曼牌 Mann'

d = File.open 'accessories_write_zf_second.text', 'rb' do |f|
  f.read  
end

m_models = JSON.parse(d)
File.open 'mann_auto_models_and_parts.json', 'wb' do |f|
  f.write(JSON.pretty_generate(m_models))
end
exit

puts "m_model count #{m_models.count}"

m_models.each do |m|
  parts = []
  m['parts'].each do |p|
    parts << {
      'part_brand_name' => mann,
      'part_type_name' => p['type'],
      'number' => p['number']
    }
  end

  data = {
    'brand_name' => m['brand_name'],
    'model_name' => m['series_name'],
    'submodel_name' => m['model_name'],
    'engine_model' => m['engine'],
    'year' => m['year'],
    'limit' => m['limit'],
    'parts' => parts
  }
  #puts JSON.pretty_generate(data)
  response_json = RestClient.post(server_address + 'auto_submodels_import', data.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "import error #{response_json.code}\n#{JSON.pretty_generate(m)}\n#{JSON.pretty_generate(data)}" or exit if response_json.code != 204
end
