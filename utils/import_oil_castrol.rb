#encoding: UTF-8
require 'json'
require 'rest_client'
require 'CSV'

server_address = 'http://127.0.0.1:3000/'
castrol = '嘉实多'

short_name_to_full_names = {
'cihu' => ['磁护 SN 5W-40 4L', '磁护 SN 5W-40 1L'],
'jihu' => ['极护 SN 0W-40 4L', '极护 SN 0W-40 1L'],
'jinjiahu' => ['金嘉护 SN 10W-40 4L', '金嘉护 SN 10W-40 1L'],
'yinjiahu' => ['银嘉护 SL 10W-40 4L', '银嘉护 SL 10W-40 1L']
}

asms = CSV.read 'lakala数据库20131129.csv', :headers => true, :encoding=>"GBK", :col_sep=>","

puts "auto submodels count #{asms.count}"

asms.each do |asm|
  parts = []

  if short_name_to_full_names[asm[3]]
    short_name_to_full_names[asm[3]].each do |fn|
      parts << {
        'part_brand_name' => castrol,
        'part_type_name' => '机油',
        'number' => fn
      } 
    end
  end

  if short_name_to_full_names[asm[4]]
    short_name_to_full_names[asm[4]].each do |fn|
      parts << {
        'part_brand_name' => castrol,
        'part_type_name' => '机油',
        'number' => fn
      } 
    end
  end

  data = {
    'service_level' => asm[5].to_i,
    'motoroil_cap' => asm[2].to_i,
    'parts' => parts
  }
  #puts JSON.pretty_generate(data)
  response_json = RestClient.post(server_address + 'auto_submodels_import_by_id/' + asm[0], data.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "import error #{response_json.code}\n#{JSON.pretty_generate(data)}" or exit if response_json.code != 204
end
