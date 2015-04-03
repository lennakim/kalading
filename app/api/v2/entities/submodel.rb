module V2
  module Entities
    class Submodel < BaseEntity
      expose :engine_displacement
      expose :submodels, using: ::V2::Entities::AutoSubmodel
    end
  end
end
