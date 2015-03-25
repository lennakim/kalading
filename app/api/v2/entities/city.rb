module V2
  module Entities
    class City < BaseEntity
      expose :id
      expose :name
      expose :districts, using: District
    end
  end
end
