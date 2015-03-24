module V2
  module Entities
    class City < Base
      expose :id
      expose :name
      expose :districts, using: District
    end
  end
end
