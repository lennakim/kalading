module V2
  module Entities
    class City < Base
      expose :id
      expose :name
      expose :districts, using: ::V2::Entities::District
    end
  end
end
