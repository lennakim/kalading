class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: Integer, default: 0
  field :title, type: String, default: ''
  field :content, type: String, default: ''
  
  has_and_belongs_to_many :cities
  auto_increment :seq
  index({ seq:1 })
  validates :title, presence: true
  validates :content, presence: true

  STATES = [0, 1, 2]
  STATE_STRINGS = %w[not_sent sent send_failed]
  
  attr_accessible :seq, :state, :title, :content, :city_ids
  
  def push
    require 'net/http'
    access_id = 2100088677
    timestamp = Time.now.to_i
    method = 'POST'
    url = 'openapi.xg.qq.com/v2/push/tags_device'
    message = {} 
    message['title'] = self.title
    message['content'] = self.content
    message = JSON.dump(message)
    message_type = 2
    tags_list = JSON.dump(self.city_ids.map {|a| a.to_s})
    tags_op = "OR"
    secret_key = '3ab015fc70c5cf87a9b3d685be7d6964'
    sign = Digest::MD5.hexdigest "#{method}#{url}access_id=#{access_id}message=#{message}message_type=#{message_type}tags_list=#{tags_list}tags_op=#{tags_op}timestamp=#{timestamp}#{secret_key}"
    params = {:sign => sign, :access_id => access_id, :message => message, :message_type => message_type, :tags_list => tags_list, :tags_op => tags_op,:timestamp => timestamp}
    uri = URI.parse('http://openapi.xg.qq.com/v2/push/tags_device')
    http = Net::HTTP.new(uri.host,uri.port)
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(params)
    req['Content-Type'] = 'application/x-www-form-urlencoded'
    res = JSON.parse(http.request(req).body)
    if res['ret_code'].to_i == 0
      self.state = 1
    else
      self.state = 2
      logger.info "notification push error: #{res['err_msg']}"
    end
  end
  
end
