#encoding: UTF-8

require 'json'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'rest_client'

server_address = 'http://127.0.0.1:3000/'

def query_jd_url_and_price(number)
  uri = 'http://search.jd.com/Search?enc=utf-8&area=1&keyword='
  uri += CGI::escape('汉格斯特')
  uri += CGI::escape(number)
  puts "Searching #{number} on jd"
  finished = false
  while !finished
    begin
    doc = Nokogiri::HTML(open(uri,
                              'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                              'Host' => 'search.jd.com'
                        ))
    
      finished = true
    rescue
      puts "exception!"
    end
  end
  
  str = ''
  doc.css('div.p-name a font').each do |font|
    str += font.content
    str.gsub!(/\s+/, "")
    if str =~ /.*#{number.gsub(/\s+/, "")}.*/
      font.parent().parent().parent().css('div.p-price strong').each do |s|
        uri = 'http://p.3.cn/prices/mgets?skuids=' + s['class']
        finished = false
        while !finished
          begin
            #+ ',&area=1_72_2799&type=1&callback=jsonp1384264867805&_=1384264867907'
            doc_price = Nokogiri::HTML(open(uri,
                                  'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                                  'Host' => 'search.jd.com',
                                  :read_timeout => 10
                            ))
            finished = true
          rescue
            puts "exception!"
          end
        end

        infos = JSON.parse(doc_price.css('p')[0].content)
        return {name: '京东', url: font.parent()['href'], price: infos[0]['p'].to_f.to_s}
      end
      break
    end
  end
  return nil
end

def query_tmall_url_and_price(number)
  uri = 'http://hengst.tmall.com/search.htm?orderType=&viewType=grid&lowPrice=&highPrice=&keyword='
  uri += CGI::escape(number.gsub(/\s+/, "+"))
  puts "Searching #{number} on tmall"
  finished = false
  while !finished
    begin
      doc = Nokogiri::HTML(open(uri,
                                'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                                'Host' => 'hengst.tmall.com',
                                :read_timeout => 10
                          ))
      finished = true
    rescue
      puts "exception!"
    end
  end
  #puts doc
  doc.css('a.item-name').each do |a|
    str = ''
    a.css('span').each do |span|
      str += span.content
    end
    str.gsub!(/\s+/, "")
    if str =~ /.*#{number.gsub(/\s+/, "")}.*/
      return {name: '天猫', url: a['href'], price: a.parent().css('div div span.c-price')[0].content.to_f.to_s}
    end
  end
  return nil
end

d = File.open 'hengst_filter.json', 'rb' do |f|
  f.read  
end
hengst_filters = JSON.parse(d)

part_number_to_type_id = {}
hengst_filters.each do |f|
  part_number_to_type_id[f['name']] = f['type']
end
puts "hengst_filter count #{part_number_to_type_id.count}"

part_number_to_id = {}
c = 0
jd_c = 0
tmall_c = 0
start = false
part_number_to_type_id.each do |number, type|
  #next if !start && number != '2010SF010'
  start = true
  a = []
  u = query_jd_url_and_price number
  a << u and jd_c += 1 if u
  u = query_tmall_url_and_price number
  a << u and tmall_c += 1 if u
  next if a.size == 0

  response_json = RestClient.get(
                               server_address + 'parts?search=' + CGI::escape(number),
                               :content_type => :json, :accept => :json){|response, request, result| response }
  puts "get part error #{response_json.code}" or exit if response_json.code != 200
  parts = JSON.parse(response_json)
  part = {
    urlinfos_attributes: a
  }
  response_json = RestClient.put(server_address + 'parts/' + parts[0]['_id'], part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
  puts "update part error #{response_json.code}" or exit if response_json.code != 204
  c += 1
  puts "Count: #{c}, jd: #{jd_c}, tmall: #{tmall_c}"
end
