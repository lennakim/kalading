class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :merge_json_params

  def check_for_mobile
    session[:mobile_override] = params[:mobile] if params[:mobile]
    #prepare_for_mobile if mobile_device?  && !params[:mobilejs]
  end

  def prepare_for_mobile
    request.format = :mobile
  end

  def mobile_device?
    #return 1
    if session[:mobile_override]
      session[:mobile_override] == "1"
    else
      # Season this regexp to taste. I prefer to treat iPad as non-mobile.
      (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
      #true
    end
  end
  helper_method :mobile_device?
  
  def after_sign_in_path_for(user)
    orders_path
  end

  def after_sign_out_path_for(user)
    orders_path
  end
  
  attr_accessor :current_order
  
  def set_default_operator
    # Not used
  end
  
  def set_locale
    if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
      session[:locale] = params[:locale]
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def merge_json_params
    if request.format.json?
      body = request.body.read
      request.body.rewind
      begin
        params.merge!(ActiveSupport::JSON.decode(body)) unless body == ""
      rescue
      end
    end
  end
  
  # 根据城市和地址，查询经纬度，例如：get_latitude_longitude '北京市', '北苑家园'
  # 如果查询成功，返回数组：[longititude, latitude]，失败返回[]
  def get_latitude_longitude(city, address)
    require 'net/http'
    ak = '227c2a3806aae1804f15cff021674ef9'
    response = Net::HTTP.get_response URI.parse('http://api.map.baidu.com/place/v2/search?q=' + CGI.escape(address) + '&region=' + CGI.escape(city) + '&output=json&ak=' + ak)
    return [] if response.code != '200'
    h = JSON.parse(response.body)
    return [] if h['status'] != 0
    return [] if h['results'].empty?
    [ h['results'][0]['location']['lng'], h['results'][0]['location']['lat'] ]
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

  def send_sms(phone_num, tpl_id, params)
    return if Rails.env.development? || Rails.env.test?
    require 'net/http'
    r = Net::HTTP.post_form URI.parse('http://yunpian.com/v1/sms/tpl_send.json'),
      {
        'apikey' => 'c9bd661a0aa53ee2fa262f1ad6c027dc',
        'mobile' => phone_num,
        'tpl_id' => tpl_id,
        'tpl_value' => params
      }
    r
  end
end
