#encoding: UTF-8

require 'json'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'rest_client'
require 'CSV'
require 'zlib'

server_address = 'http://127.0.0.1:3000/'

def query_jd_url_and_price(brand_name, number)
  uri = 'http://search.jd.com/Search?enc=utf-8&area=1&keyword='
  uri += CGI::escape(brand_name + ' ')
  uri += CGI::escape(number)
  puts "Searching #{brand_name} #{number} on jd"
  finished = false
  while !finished
    begin
      stream = open(uri,
                    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                    'Accept-Language' => 'zh-CN,zh;q=0.8,en;q=0.6',
                    'Accept-Encoding' => 'gzip,deflate,sdch',
                    'Cache-Control' => 'max-age=0',
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                    'Host' => 'search.jd.com'
                    )
      if (stream.content_encoding.empty?)
        body = stream.read
      else
        body = Zlib::GzipReader.new(stream).read
      end
      doc = Nokogiri::HTML(body)
      finished = true
    rescue
      puts "exception for #{uri}"
    end
  end

  urls = []
  doc.css('ul.list-h li').each do |li|
    str = ''
    li.css('div.p-name a').each do |a|
      str += a.content
      str.gsub!(/\s+/, "")
      if str =~ /.*#{number.gsub(/\s+/, "")}.*/i
        a.parent().parent().css('div.p-price strong').each do |s|
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
              puts "exception on #{uri}!"
            end
          end
          infos = JSON.parse(doc_price.css('p')[0].content)
          urls << {name: '京东', url: a['href'], price: infos[0]['p'].to_f.to_s}
        end
        break
      end
    end
  end
  urls
end

asms = CSV.read 'parts.csv', :headers => true, :encoding=>"utf-8", :col_sep=>","

puts "Parts: #{asms.count}"

c = 0
File.open 'search_part_price_on_jd.log', 'w' do |log|
  File.open 'part_prices_found.csv', 'w' do |f|
    asms.each do |asm|
      a = query_jd_url_and_price asm[1], asm[2]
      next if a.empty?
      part = {
        urlinfos_attributes: a
      }
      #puts JSON.pretty_generate part
      response_json = RestClient.put(server_address + 'parts/' + asm[0], part.to_json,:content_type => :json, :accept => :json){|response, request, result| response }
      if response_json.code != 204
        log.puts "update #{asm[0]} error #{response_json.code}"
      else
        f.puts "#{asm[0]}"
        c += 1
      end
    end
  end
end

puts "Parts with price: #{c}"
