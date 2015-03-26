module V2
  module Entities
    class AutoSubmodel < BaseEntity
      expose :id
      expose :name
      expose :model
      expose :brand
      expose :full_name
      expose :pictures, using: Picture
    end
  end
end