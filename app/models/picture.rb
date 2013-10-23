class Picture
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :order, :inverse_of => :pictures
  embedded_in :auto_submodel, :inverse_of => :pictures

  has_mongoid_attached_file :p, :styles => { small: 'x100' }, :url => "/system/:class/:id/p/:style.:extension"
end
