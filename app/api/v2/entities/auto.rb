module V2
  module Entities
    class Auto < BaseEntity
      expose :initial
      expose :autos, using: ::V2::Entities::AutoBrand
    end
  end
end
