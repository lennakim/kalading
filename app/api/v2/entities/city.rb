module V2
  module Entities
    class City < BaseEntity
      expose :id
      expose :name
      expose :districts, using: ::V2::Entities::District
    end
  end
end
