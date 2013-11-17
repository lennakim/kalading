#encoding: UTF-8
require 'json'
require 'cgi'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

#response_json = RestClient.get(
#                             server_address + 'parts.json?has_urlinfo=1',
#                             :content_type => :json, :accept => :json){|response, request, result| response }
#puts "get parts error #{response_json.code}" or exit if response_json.code != 200
#parts = JSON.parse(response_json)
#hengst_parts = []
#parts.each do |p|
#  next if p['brand_name'] != '汉格斯特'
#  oc = p['urlinfos_attributes'].count
#  next if oc == 0
#  p['urlinfos_attributes'].uniq! { |x| x['name'] }
#  puts "#{oc} -> #{p['urlinfos_attributes'].count}" if oc != p['urlinfos_attributes'].count
#  part_info = {
#    urlinfos_attributes: p['urlinfos_attributes']
#  }
#  hengst_parts << p
#  #response_json = RestClient.put(server_address + 'parts/' + p['_id'], part_info.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
#  #puts "update part #{p['number']} error #{response_json.code}" or exit if response_json.code != 204
#end
#
#File.open 'hengst_urlinfos.json', 'wb' do |f|
#  f.write JSON.pretty_generate(hengst_parts)
#end

d = File.open 'hengst_urlinfos.json', 'rb' do |f|
  f.read
end
parts = JSON.parse(d)
#puts JSON.pretty_generate(parts)
puts parts.count

parts.each do |p|
  part_info = {
    urlinfos_attributes: p['urlinfos_attributes']
  }
  response_json = RestClient.put(server_address + 'parts/' + p['_id'], part_info.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "update part #{p['number']} error #{response_json.code}" or exit if response_json.code != 204
end

