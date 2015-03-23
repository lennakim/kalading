class Engineer < User
  include Mongoid::Document

  field :roles,    :type => Array, :default => [5]
end
