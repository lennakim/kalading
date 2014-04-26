class Video
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url, type: String
  field :engineer_name, type: String
  field :bytes, type: Integer, default: 0
  field :create_time, type: DateTime, default: lambda { self.created_at }
  
  attr_accessible :url, :engineer_name, :bytes, :create_time
end
