class Picture
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :order, :inverse_of => :pictures
  embedded_in :auto_submodel, :inverse_of => :pictures
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
  has_mongoid_attached_file :p, :path => ":class/:attachment/:id/:basename.:extension"
  validates_attachment_content_type :p, :content_type => %w(image/jpeg image/jpg image/png)
end
