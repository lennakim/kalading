module V2
  module Entities
    class AutoModel < BaseEntity
      expose :id
      expose :name
      # expose :auto_submodels, using: AutoSubmodel
    end
  end
end
