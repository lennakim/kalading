module V2
  module Entities
    class Submodel < BaseEntity
      expose :year_range
      expose :submodels, using: ::V2::Entities::AutoSubmodel
    end
  end
end
