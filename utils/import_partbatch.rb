#encoding: UTF-8
require 'json'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

d = File.open 'json.text', 'rb' do |f|
  f.read  
end
pbs = JSON.parse(d)
puts "part batch count #{pbs.count}"

pbs.each do |pb|
  response_json = RestClient.post(server_address + 'partbatch_import', pb.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "import error #{response_json.code}\n#{JSON.pretty_generate(pb)}" or exit if response_json.code != 200
  puts "import error #{response_json.to_s}\n#{JSON.pretty_generate(pb)}" or exit if response_json != 'ok'
end
