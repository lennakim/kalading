#encoding: UTF-8

require 'json'
require 'nokogiri'
#OpenURI is an easy-to-use wrapper for net/http, net/https and net/ftp
require 'open-uri'
require 'cgi'
require 'zlib'

def get_comment_page(uri, filename)
  finished = false
  while !finished
    begin
      stream = open(uri,
                    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                    'Accept-Language' => 'zh-CN,zh;q=0.8,en;q=0.6',
                    'Accept-Encoding' => 'gzip,deflate,sdch',
                    'Cache-Control' => 'max-age=0',
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                    #'If-Modified-Since' => 'Fri,29 Nov 2013 01:51:52GMT',
                    #'Cookie' => 'bview=3762.10247901|3762.10139940|3762.10065499|3395.10202331|3395.10013988|3395.10240007|3395.10546770|3395.11155900; btw=3395.10202331.12|3762.10247901.9; bdshare_firstime=1375446583616; abtest=20131016210623840_84; _jzqa=1.223220971518946140.1367889935.1381929606.1382250830.36; _jzqc=1; _jzqx=1.1367889935.1382250830.36.jzqsr=item%2Ejd%2Ecom|jzqct=/1003080201%2Ehtml.jzqsr=item%2Ejd%2Ecom|jzqct=/1024245593%2Ehtml; __v=1.862775576934325400.1378562461.1381929713.1382250834.16; __l=225518788; __lstinst=186650096; __utma=122270672.576549306.1368093217.1381930101.1384170353.18; __utmc=122270672; __utmz=122270672.1384170353.18.18.utmcsr=trade.jd.com|utmccn=(referral)|utmcmd=referral|utmcct=/order/getOrderInfo.action; _pst=sepia; pin=sepia; unick=jd_sepi121; _tp="6Bs4rkfjDoRW/s9x9yiZzQ=="; eb=0; user-key=19dde609-5c78-422a-b7ae-b788fa2c6ce6; cn=0; aview=6762.542634|6762.274886|6762.274884|6762.480607|6762.1042855517|6765.482577|9971.1055004085|6765.1043535710; atw=6762.542634.13|6765.482577.0|9971.1055004085.-4|7003.1014326119.-12|6764.1042875981.-16|688.751660.-16|6763.542583.-18|693.896813.-19; ipLocation=%u5317%u4EAC; areaId=1; ipLoc-djd=1-72-2799-0; __jda=122270672.1788372091.1364003627.1385645982.1385689562.119; __jdc=122270672; __jdv=122270672|54.248.126.168:8002|-|referral|-; _jzqco=%7C%7C%7C%7C1382339720172%7C1.1856623031.1366638720470.1385689880632.1385689908433.1385689880632.1385689908433..0.0.1260.1260; __jdu=1788372091',
                    'Host' => 'club.jd.com'
                    )
      if (stream.content_encoding.empty?)
        body = stream.read
      else
        body = Zlib::GzipReader.new(stream).read
      end

      doc = Nokogiri::HTML(body)
      finished = true
    rescue
      puts "exception!"
    end
  end
  File.open filename, 'wb' do |f|
    doc.write_html_to f
  end
  #doc.css('div.mc').each do |cc|
  #  puts cc.text.gsub /\s/, ''
  #end
end

$part_numbers = {}
$gui_count = 0

def parse_comment_page(filename)
  begin
    doc = Nokogiri::HTML(open(filename).read)
  rescue
    puts "parse_comment_page exception!"
  end

  doc.css('div.comment-content').each do |cc|
    cc.css('dt').each do |dt|
      if dt.text =~ /.*尺.*码.*/
        n = dt.parent().css('dd').text.gsub /\s/, ''
        if $part_numbers[n].nil?
          $part_numbers[n] = 1
        else
         $part_numbers[n] = $part_numbers[n] + 1
        end
      end
      if dt.text =~ /.*标.*签.*/
        #puts dt.parent().css('dd').text.gsub /\s/, ''
        #$gui_count = $gui_count + 1 if dt.parent().css('dd').text =~ /(.*贵.*)|(.*价.*)|(.*便宜.*)|(.*划算.*)|(.*￥.*)|(.*钱.*)/
      end
      if dt.text =~ /.*心.*得.*/
        $gui_count = $gui_count + 1 if dt.parent().css('dd').text =~ /(.*贵.*)|(.*价.*)|(.*便宜.*)|(.*划算.*)|(.*￥.*)|(.*钱.*)|(.*实惠.*)/
      end
    end
  end
end

#File.open 'out.json', 'rb' do |f|
#  d = f.read
#  ps = JSON.parse d
#  sum = 0
#  ps.each do |k, v|
#    sum = sum + v
#  end
#  puts sum
#  ps1 = ps.sort_by {|_key, value| value}.reverse
#  puts JSON.pretty_generate ps1
#end

(1..647).each do |page|
  parse_comment_page "mann_oilf_#{page}.html"
end

(1..1248).each do |page|
  parse_comment_page "bosch_oilf_#{page}.html"
end

puts "gui count: #{$gui_count}"

#File.open 'out.json', 'wb' do |f|
#  f.write JSON.pretty_generate($part_numbers)
#end

#(3..647).each do |page|
#  uri = "http://club.jd.com/review/542634-0-#{page}-0.html"
#  get_comment_page(uri, "mann_oilf_#{page}.html")
#end
#
#(1..1248).each do |page|
#  uri = "http://club.jd.com/review/274886-0-#{page}-0.html"
#  get_comment_page(uri, "bosch_oilf_#{page}.html")
#end
