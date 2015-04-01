module V2
  module Entities
    class AutoBrand < BaseEntity
      expose :id
      expose :name
      expose :name_pinyin
      # expose :auto_models, using: AutoModel
    end
  end
end
