#encoding: UTF-8

require 'mysql2'
require 'json'
require 'rest_client'

client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root",:password=>"anycomm",:database=>"car")

mms = client.query("select * from m_model")
ahms = client.query("select * from ah_model")

matched = 0
unmatched = 0
empty_manpai = 0
empty_ah = 0

nonempty_ah_engines = ahms.select do |h|
  j = JSON.parse(h['detail'])
  j && j['发动机'] && j['发动机']['发动机型号'] && j['发动机']['发动机型号'] != '' && j['发动机']['发动机型号'] != '-'
end
puts "nonempty_ah_engines #{nonempty_ah_engines.size}"

ah_engines = nonempty_ah_engines.map do |h|
  j = JSON.parse(h['detail'])
  j['发动机']['发动机型号'].gsub(/\s+/, "")
end

nonempty_m_engines = mms.select do |h|
  h['engine'] != ''
end

puts "nonempty_m_engines #{nonempty_m_engines.size}"

m_engines = nonempty_m_engines.map do |h|
  h['engine']
end

puts "#{ah_engines.size}, #{m_engines.size}"

ah_engines.uniq!
m_engines.uniq!
puts "#{ah_engines.size}, #{m_engines.size}, #{(ah_engines & m_engines).size}"
exit

parts = JSON.parse(IO.read('idLink.txt'))
parts.each do |part|
  part["matched_ah_models"].each do |id|
    results = client.query("select * from ah_model where id=" + id.to_s)
    results.each do |h|
      j = JSON.parse(h['detail'])
      if !j || !j['发动机'] || !j['发动机']['发动机型号']
        puts "发动机型号不存在： #{h['brand_name'] + ' ' + h['series_name'] + ' ' + h['model_name']}"
      else
        if j['发动机']['发动机型号'].gsub(/\s+/, "").casecmp(part["engine"].gsub(/\s+/, "")) != 0
          #puts "发动机型号不匹配： #{j['发动机']['发动机型号']}, #{part}"
          unmatched += 1
          if part["engine"] == ''
            empty_manpai += 1
          elsif j['发动机']['发动机型号'] == '-'
            empty_ah += 1
          end
        else
          matched += 1
        end
      end
    end
  end
end
puts "#{unmatched}, #{matched}, #{empty_manpai}, #{empty_ah}"
exit

results = client.query("select * from ah_model")
auto_brands_name_to_id = {}
auto_model_name_to_id = {}

results.each do |h|
  if !auto_brands_name_to_id[h['brand_name']]
    r = { 
      name: h['brand_name']
    }
    response_json = RestClient.post("http://192.168.1.101:3000/auto_brands", r.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
    if response_json.code == 201
      auto_brands_name_to_id[h['brand_name']] = JSON.parse(response_json)['_id']
    end
  end

  if !auto_brands_name_to_id[h['brand_name']]
    puts "#{h['brand_name']} not found"
    break
  end

  if !auto_model_name_to_id[h['series_name']]
    m = { 
        name: h['series_name'],
        auto_brand_id: auto_brands_name_to_id[h['brand_name']]
    }
    response_json = RestClient.post("http://192.168.1.101:3000/auto_models", m.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
    if response_json.code == 201
      auto_model_name_to_id[h['series_name']] = JSON.parse(response_json)['_id']
    end
  end
  if !auto_model_name_to_id[h['series_name']]
    puts "#{h['series_name']} not found"
    break
  end

  j = JSON.parse(h['detail'])
  
  if !j || !j['发动机'] || !j['发动机']['发动机型号']
    j = {'发动机' => {'发动机型号' => ''}}
  end
  if !j || !j['发动机'] || !j['发动机']['排量(L)']
    j = {'发动机' => {'排量(L)' => ''}}
  end

  sm = { 
        name: h['brand_name'] + ' ' + h['series_name'] + ' ' + h['model_name'],
        auto_model_id: auto_model_name_to_id[h['series_name']],
        engine_model: j['发动机']['发动机型号'],
        engine_displacement: j['发动机']['排量(L)']
  }
  response_json = RestClient.post("http://192.168.1.101:3000/auto_submodels", sm.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  if response_json.code != 201
    puts "error create submodel #{h['model_name']}, #{response_json.code}"
    break
  end
  #break
end
