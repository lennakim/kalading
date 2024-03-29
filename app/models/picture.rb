# 图片
class Picture

  delegate :url, :size, to: :p # api

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :order, :inverse_of => :pictures
  embedded_in :auto_submodel, :inverse_of => :pictures
  embedded_in :auto_brand, :inverse_of => :picture
  embedded_in :wheel, :inverse_of => :pictures
  embedded_in :tool_record, :inverse_of => :pictures
  embedded_in :maintain, :inverse_of => :outlook_pics
  embedded_in :maintain, :inverse_of => :oil_pics
  embedded_in :maintain, :inverse_of => :air_filter_pics
  embedded_in :maintain, :inverse_of => :cabin_filter_pics
  embedded_in :maintain, :inverse_of => :tire_left_front_pics
  embedded_in :maintain, :inverse_of => :tire_left_back_pics
  embedded_in :maintain, :inverse_of => :tire_right_front_pics
  embedded_in :maintain, :inverse_of => :tire_right_back_pics
  embedded_in :maintain, :inverse_of => :tire_spare_pics
  embedded_in :maintain, :inverse_of => :oil_and_battery_pics

  field :desc, type: String, default: ''
  #1: verified, 0: unverified
  field :state, type: Integer, default: 0
  STATES = [0, 1]
  STATE_STRINGS = %w[unverified verified]
  belongs_to :user
  has_mongoid_attached_file :p, :path => ":class/:attachment/:id/:basename.:extension"
  validates_attachment_content_type :p, :content_type => %w(image/jpeg image/jpg image/png)

end
