class Picture
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :order, :inverse_of => :pictures
  embedded_in :auto_submodel, :inverse_of => :pictures
  embedded_in :wheel, :inverse_of => :pictures
  embedded_in :tool_record, :inverse_of => :pictures
  embedded_in :iamge_text, :inverse_of => :pictures
  embedded_in :maintain, :inverse_of => :outlook_pic
  embedded_in :maintain, :inverse_of => :auto_front_pic
  embedded_in :maintain, :inverse_of => :auto_back_pic
  embedded_in :maintain, :inverse_of => :auto_left_pic
  embedded_in :maintain, :inverse_of => :auto_right_pic
  embedded_in :maintain, :inverse_of => :auto_top_pic
  embedded_in :maintain, :inverse_of => :old_oil_pic
  embedded_in :maintain, :inverse_of => :oil_filter_pic
  embedded_in :maintain, :inverse_of => :old_air_filter_pic
  embedded_in :maintain, :inverse_of => :old_cabin_filter_pic
  embedded_in :maintain, :inverse_of => :tire_left_front_pic
  embedded_in :maintain, :inverse_of => :tire_left_back_pic
  embedded_in :maintain, :inverse_of => :tire_right_front_pic
  embedded_in :maintain, :inverse_of => :tire_right_back_pic
  embedded_in :maintain, :inverse_of => :tire_spare_pic

  has_mongoid_attached_file :p, :styles => { small: 'x100' }, :url => "/system/:class/:id/p/:style.:extension"
end
