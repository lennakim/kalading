require 'net/http'
module Map
  extend self
  # 根据城市和地址，查询经纬度，例如：get_latitude_longitude '北京市', '北苑家园'
  # 如果查询成功，返回数组：[longititude, latitude]，失败返回[]
  def get_latitude_longitude(city, address)
    return [116.4074, 39.9042] if Rails.env.test?
    ak = '227c2a3806aae1804f15cff021674ef9'
    response = Net::HTTP.get_response URI.parse('http://api.map.baidu.com/place/v2/search?q=' + CGI.escape(address) + '&region=' + CGI.escape(city) + '&output=json&ak=' + ak)
    return [] if response.code != '200'
    h = JSON.parse(response.body)
    return [] if h['status'] != 0
    return [] if h['results'].empty?
    begin
      [ h['results'][0]['location']['lng'], h['results'][0]['location']['lat'] ]
    rescue
      []
    end
  end
  
  RAD_PER_DEG = 0.017453293  #  PI/180
  Rkm = 6371              # radius in kilometers...some algorithms use 6367
  Rmeters = Rkm * 1000    # radius in meters

  # 计算两点之间的距离，单位为米。输入参数为两个经纬度数组
  def haversine_distance( lng_lat1, lng_lat2 )
    dlon = lng_lat2[0] - lng_lat1[0]
    dlat = lng_lat2[1] - lng_lat1[1]
    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG
    lat1_rad = lng_lat1[1] * RAD_PER_DEG
    lat2_rad = lng_lat2[1] * RAD_PER_DEG
    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    dMeters = Rmeters * c
    dMeters
  end
end
