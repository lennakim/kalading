require 'net/ftp'
require 'uri'
# 视频
class Video
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, type: String
  # 废弃字段
  field :engineer_name, type: String
  field :phone_num, type: String
  # 视频大小
  field :bytes, type: Integer, default: 0
  # 拍摄时间，取自相机
  field :create_time, type: DateTime, default: lambda { self.created_at }
  # 是否可以删除
  field :can_delete, type: Boolean, default: true

  belongs_to :city
  belongs_to :engineer
  attr_accessible :url, :engineer_name, :bytes, :create_time, :can_delete, :city_id, :phone_num

  before_destroy :delete_remote_file
  def delete_remote_file
    return if !Rails.env.production?
    begin
      uri = URI self.url
      ftp = Net::FTP.new(uri.host)
      ftp.login 'kalading', 'Kalading123'
      ftp.delete uri.path[1..-1]
      ftp.quit()
    rescue
    end
  end

end
