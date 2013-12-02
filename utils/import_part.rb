#encoding: UTF-8

require 'json'
require 'rest_client'

#server_address = 'http://192.168.1.101:3000/'
server_address = 'http://54.248.126.168:8002/'

#导入机滤: 汉格斯特H97W07，并匹配力帆620 1.6L 发动机型号为LF481Q3的所有车型，建立对应关系

# 查找车型力帆620，排量1.6L， 发动机型号为LF481Q3的所有车型
# 使用正则表达式匹配关键字 力帆620 和 1.6L, .*表示任意字符串
response_json = RestClient.get(server_address + 'auto_submodels?' + 'search=' + CGI::escape('力帆620.*1.6L'), :content_type => :json, :accept => :json){|response, request, result| response }
puts "get auto_submodel error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
auto_submodels = JSON.parse(response_json)

# 机滤H97W07只能用于发动机型号LF481Q3，所以取出所有发动机型号为LF481Q3的车型
auto_submodels = auto_submodels.select {|x| x['engine_model'] == 'LF481Q3'}
# 取出所有车型ID
match_auto_submodel_ids = auto_submodels.map {|x| x['_id']}
puts "共匹配#{match_auto_submodel_ids.count}个车型"

#获取配件类型列表
response_json = RestClient.get(server_address + 'part_types', :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_types = JSON.parse(response_json)

part_type_to_ids = {}
part_types.each do |pt|
  part_type_to_ids[pt['name']] = pt['_id']
end
puts '机滤的part_type_id: ' + part_type_to_ids['机滤']

#获取配件品牌列表
response_json = RestClient.get(server_address + 'part_brands', :content_type => :json, :accept => :json){|response, request, result| response }
puts "get part_types error #{response_json.code}" or exit if response_json.code != 200
#puts JSON.pretty_generate(JSON.parse(response_json))
part_brands = JSON.parse(response_json)

part_brand_to_ids = {}
part_brands.each do |pt|
  part_brand_to_ids[pt['name']] = pt['_id']
end
puts '汉格斯特的part_brand_id: ' + part_brand_to_ids['汉格斯特']

#导入机滤: Hengst汉格斯特机油滤清器H97W07
part = {
  #制造商型号
  number: 'H97W07',
  # 容量(油类单位是升，零件单位是个)
  capacity: '1',
  # 特殊匹配规则
  match_rule: '',
  # 规格
  spec: '',
  # 机滤类型ID
  part_type_id: part_type_to_ids['机滤'],
  # 汉格斯特品牌ID
  part_brand_id: part_brand_to_ids['汉格斯特'],
  # 网站链接
  urlinfos_attributes: [
    {
      name: '淘宝',
      url: 'http://detail.tmall.com/item.htm?spm=a1z10.3.w4011-3180141103.19.L9qukX&id=19587150982&rn=888cbd3edc4bd1e671bc81786ea6d642&&&scene=taobao_shop'
    }
  ],
  # 此配件适用的车型ID列表
  auto_submodel_ids: match_auto_submodel_ids
}
  
response_json = RestClient.post(server_address + 'parts', part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
puts "Create part error #{response_json.code}", "#{response_json}" or exit if response_json.code != 201
puts '导入配件成功'
puts JSON.pretty_generate(JSON.parse(response_json))




