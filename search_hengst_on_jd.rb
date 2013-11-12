#encoding: UTF-8

require 'json'
require 'nokogiri'
require 'open-uri'
require 'cgi'

#number = 'E27H D84'
number = 'E27H D125'
uri = 'http://search.jd.com/Search?enc=utf-8&area=1&keyword='
uri += CGI::escape('汉格斯特')
uri += CGI::escape(number)
doc = Nokogiri::HTML(open(uri,
                          'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                          'Host' => 'search.jd.com'
                    ))

str = ''
doc.css('div.p-name a font').each do |font|
  str += font.content
  str.gsub!(/\s+/, "")
  if str =~ /.*#{number.gsub(/\s+/, "")}.*/
    font.parent().parent().parent().css('div.p-price strong').each do |s|
      uri = 'http://p.3.cn/prices/mgets?skuids=' + s['class']
      #+ ',&area=1_72_2799&type=1&callback=jsonp1384264867805&_=1384264867907'
      doc_price = Nokogiri::HTML(open(uri,
                            'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
                            'Host' => 'search.jd.com'
                      ))
      doc_price.css('p').each do |p|
        puts p.content
        infos = JSON.parse(p.content)
        puts infos[0]['p'].to_i
      end
    end
    break
  end
end